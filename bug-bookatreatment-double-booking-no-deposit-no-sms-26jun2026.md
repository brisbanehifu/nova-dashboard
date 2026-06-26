# BUG INVESTIGATION — BookATreatment (Brisbane HIFU prod)

**Date:** 2026-06-26
**Reported by:** Kim
**Severity:** P1 — revenue leak + booking integrity + comms failure (three faults in one journey)
**Client affected:** Heather Gettings (new client)
**Symptoms:**
1. New client was able to **book TWICE** (two appointments today).
2. **No deposit / no payment** taken on either booking.
3. **No booking-confirmation SMS** received for either appointment.

> ⚠️ **Scope note.** The booking app source lives in the **private repo
> `brisbanehifu/booking-api`** (Node/Express + React, deployed on Railway, MySQL DB).
> This session is scoped to `nova-dashboard` only, so the code fixes below **cannot be
> pushed from here** — they must land in `booking-api`. This document is the
> investigation + fix plan. Findings were reconstructed from `booking-api` via GitHub
> code search (read-only) plus the prior session handovers in this repo.

---

## TL;DR — three independent faults stacked on one client

| # | Symptom | Root cause | Status |
|---|---------|-----------|--------|
| A | Booked twice, no block | Dedup phone-normaliser doesn't canonicalise AU numbers (`0416…` ≠ `+61416…`); dedup is fail-open (no DB lock/constraint); "keep both" allowed by design | **NEW finding** — code gap in `bookings.js` |
| B | No deposit / paid nothing | Public booking POST creates `payment_status='unpaid'` with **no server-side deposit gate**; Stripe Connect pipeline **paused 9 May 2026**; deposit only ever attempted if `event_types.deposit_required=1` (default `0`) | **KNOWN OPEN** — backlog item R4 "Deposit enforcement (REVENUE LEAK)" |
| C | No confirmation SMS | ClickSend unregistered-sender carrier filtering (Telstra/Vodafone silently drop); `notification_logs.status='sent'` is a claim, not delivery. Possibly compounded by phone-format / env regression | **KNOWN ISSUE** — see 13 May ClickSend handover |

These are **three separate bugs** that happened to all hit Heather. Fixing one does not fix the others.

---

## A. Double booking — why nothing stopped it

### What the code does
The public `POST /api/bookings` runs a soft de-dup (R9, PR #487, 26 May 2026) before
creating a booking — `booking-api/bookings.js`:

```js
async function findFutureDuplicates({ phone, tenantId, withinDays = 30, excludeBookingId = null }) {
  const norm = normalizePhoneForDedup(phone);
  // ...
  //   AND date >= CURDATE()
  //   AND date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
  //   AND status NOT IN ('cancelled', 'completed', 'no-show', 'no_show')
}
```

```js
// Skipped when: caller is admin (isAdminOverride), phone is empty/invalid,
// or the customer explicitly chose 'keep_both' on the modal.
function normalizePhoneForDedup(phone) {
  if (typeof phone !== 'string') return null;
  const digits = phone.replace(/[^0-9]/g, '');   // <-- raw digits only
  if (digits.length < 6) return null;
  // ...
}
```

When a duplicate IS found the API returns `needs_confirmation: true` and the frontend
shows `DuplicateBookingModal`, letting the customer **Replace** or **Keep both**.

### Why Heather got through (most → least likely)

1. **Phone normalisation gap (primary suspect).** `normalizePhoneForDedup` strips to raw
   digits but does **not** canonicalise the Australian country code. So the *same phone*
   entered two different ways produces two different keys:
   - `0416 248 639` → `0416248639` (10 digits)
   - `+61 416 248 639` / `61416248639` → `61416248639` (11 digits)

   These don't compare equal, so the second submission is **not** seen as a duplicate →
   no modal → silent second booking. New clients very commonly retype their number in a
   different format on a second attempt (or one came from a saved contact in `+61` form).

2. **Fail-open race condition.** Dedup is a read-then-insert with **no DB uniqueness
   constraint or row lock**. Two near-simultaneous public submits (double-tap on a slow
   network, two browser tabs, an auto-retry) can both read "zero duplicates" before either
   row commits → both insert. The design is explicitly fail-open.

3. **"Keep both" is allowed by design.** Even when the modal fires, the customer can choose
   Keep both — two future bookings is a supported outcome.

4. **Broken reschedule-link path (documented in code).** Per the `DuplicateBookingModal.tsx`
   / `bookings.js` comments, the canonical R9 scenario is: customer clicks a broken
   `/reschedule/<token>` link → lands on the error page → clicks "Make a new booking" →
   creates a SECOND booking while the original sits untouched.

### Fix (booking-api)
- **Canonicalise to E.164 before comparing.** In `normalizePhoneForDedup`, map AU numbers
  to one form: strip non-digits, then `0XXXXXXXXX` → `61XXXXXXXXX` (and handle a leading
  `+`). Store/compare the canonical form. Apply the *same* canonicalisation everywhere a
  phone is saved or matched (contacts, SMS send).
- **Close the race.** Add a DB guard — a unique index on
  `(tenant_id, normalized_phone, date, time)` for active statuses, or a short advisory lock
  around the read-then-insert — so concurrent identical submits can't both land.
- Consider tightening the same-day case: a second booking for the same phone on the **same
  date** should always prompt, even inside the 30-day window logic.

---

## B. No deposit / booked without paying — the known revenue leak (R4)

### What the code does
- Deposit is only attempted when the service is flagged. `booking-api/jose-booking.js`:
  ```js
  if (price <= 0) return { amount: 0, charge: false };
  if (!svc.deposit_required) return { amount: price, charge: true }; // pay full up-front
  const dep = Number(svc.deposit) || 0;
  ```
- `event_types.deposit_required` defaults to **0** (migration `008_service_deposit_waiver.sql`
  / `migrate.js`: `TINYINT(1) DEFAULT 0`). A service that was never ticked "require a deposit"
  charges nothing at booking.
- Bookings are inserted **`payment_status='unpaid'`** and treated as confirmed regardless of
  payment (pattern seen in `neo-v2.js`: `'confirmed', 'unpaid', 0`). There is **no
  server-side gate** that refuses to confirm a booking when a deposit is owed.

### Why this is already a known issue
This is backlog item **R4 — "Deposit enforcement on bookings (REVENUE LEAK)"** from the
26 May 2026 session ("Start here next session"). Its own example is identical in shape to
Heather: *"Elisse Walker, FIRST visit … slideout shows DEPOSIT TOTAL: $0.00 · Unpaid.
Should have been blocked at booking time."*

Two blockers were recorded:
1. **Stripe Connect pipeline was PAUSED on 9 May 2026** (standing-rule memory
   `stripe_pipeline_pause_9may2026`) — so the "Send Deposit SMS" recovery button is disabled
   and no card payment is collected at booking time.
2. **Open product questions for Kim** (unanswered, needed before coding):
   - Enforce deposit on **all** services that have one configured, or only a subset
     (first-visits / $-threshold / specific services / paid only)?
   - Is the gap server-side (`POST /api/bookings` accepts without a deposit field) or
     front-end (public flow lets the customer skip the payment step)? *(Investigation
     points to **server-side** — there is no enforcing check.)*
   - Which sources should keep bypassing deposit by design (admin-created, "AGAIN"
     rebookings, reschedules via the dedup flow)?

PRs #488/#489 only added a **"Pending Deposit" chase-queue chip** to the admin Bookings
page — that surfaces unpaid bookings after the fact; it does **not** block booking without
payment.

### Fix (booking-api) — needs Kim's product call first
- Re-enable the Stripe Connect deposit pipeline (paused 9 May) — prerequisite.
- Add server-side enforcement in `POST /api/bookings`: when the service requires a deposit
  (or `price ≥` tenant `deposit_required_threshold_aud`), do **not** create a `confirmed`
  booking without a paid deposit / valid PaymentIntent. Instead create
  `status='pending_deposit'` (hold) and only confirm on payment success.
- Mirror the gate in the public `BookingPage.tsx` payment step so the customer can't skip it.

---

## C. No confirmation SMS (both bookings)

### Most likely cause — carrier filtering of an unregistered sender
Per the **13 May 2026 ClickSend migration handover** (this repo), an SMS showing
`notification_logs.status='sent'` (and even ClickSend `status_text="Message delivered to
the handset"`) is **a claim, not a delivery**:
- ClickSend's Smart Sender was sending Brisbane HIFU SMS from a **rotating shared numeric
  pool** because no alpha tag was registered.
- **Telstra and Vodafone silently filter** unregistered numeric senders even when ClickSend
  reports "delivered to network."
- The **BRISHIFU alpha tag** was filed 14 May and was **PENDING ACMA approval** (24–72h).

### Things to verify (today)
1. **Is BRISHIFU alpha tag now ACMA-approved and active in ClickSend?** If it lapsed/was
   never approved, sends are still going out on shared numbers and being dropped.
2. **Env regression check.** On 13 May there was a P0 where ClickSend silently reformatted
   the master `api_username` (`Brisbane.HIFU.clinic@gmail.com` → `BrisbaneHifu`), making
   every send return **401** until `CLICKSEND_USERNAME` was fixed on Railway. Confirm the
   Railway env var still matches the live ClickSend username and that recent sends aren't 401.
3. **Heather's stored number format.** If saved non-E.164, ClickSend may have rejected the
   send outright. (Same normalisation gap as fault A — fixing A helps here too.)
4. **Pull the actual DLR** for Heather's number in the ClickSend dashboard/API — don't trust
   `status='sent'`.

### Fix (booking-api / ops)
- Ops: confirm the alpha tag is live; confirm `CLICKSEND_USERNAME` env; pull DLRs.
- Code: normalise recipient numbers to E.164 before send; treat ClickSend `sent` as
  *accepted*, surface real DLR status in `notification_logs` so "sent" stops masking
  non-delivery.

---

## Immediate actions for Kim (today, no code needed)
1. Open Heather Gettings' two bookings in admin → check the **phone format on each**, the
   **deposit/payment status**, and the **notification_logs** rows. (This confirms fault A's
   normalisation theory and fault C's delivery.)
2. **Call/message Heather** to confirm which appointment she actually wants, cancel the
   duplicate, and take the deposit/payment manually.
3. Check the **ClickSend dashboard** for the BRISHIFU alpha-tag status and the DLRs for her
   number.

## Recommended fix order (in booking-api)
1. **C (SMS) ops checks** — fastest, may be pure config (alpha tag / env). Restores comms.
2. **A (dedup normalisation + race guard)** — contained code fix in `bookings.js`, stops
   silent double bookings.
3. **B (deposit enforcement)** — biggest, needs Kim's product answers + Stripe pipeline
   un-pause. This is the revenue fix (R4).

---

### Files implicated (booking-api)
- `bookings.js` — `findFutureDuplicates`, `normalizePhoneForDedup`, public `POST /api/bookings`
- `frontend/src/pages/booking/BookingPage.tsx`, `frontend/src/components/booking/DuplicateBookingModal.tsx`, `frontend/src/lib/api.ts` — dedup modal
- `jose-booking.js`, `event-types.js`, `pay-redirect.js`, `deposit-reconcile-cron.js` — deposit/Stripe
- `db/migrations/008_service_deposit_waiver.sql`, `migrate.js` — `deposit_required` schema (default 0)
- `notifications.js`, `src/api/notifications/service.ts`, `docs/notifications/TRIGGER_MAP.md` — SMS/email triggers (ClickSend)

_Investigation by Claude · 2026-06-26 · branch `claude/book-treatment-double-booking-jjq53f`._
</content>
</invoke>
