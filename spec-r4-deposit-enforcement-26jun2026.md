# SPEC — R4: Deposit Enforcement on Bookings (revenue leak)

**Date:** 2026-06-26
**Owner decision needed:** Kim (product questions in §4)
**Target repo:** `brisbanehifu/booking-api` (not pushable from this session)
**Related:** `bug-bookatreatment-double-booking-no-deposit-no-sms-26jun2026.md` (fault B),
backlog R4 (26 May 2026), standing-rule `stripe_pipeline_pause_9may2026`
**Triggering incident:** Heather Gettings booked twice, paid $0 on both.

---

## 1. Problem
Clients can confirm a booking for a deposit-required service **without paying anything**.
The booking is created and treated as `confirmed` with `payment_status='unpaid'`, and nothing
recovers the payment automatically. This is a direct revenue leak and the reason Heather's two
bookings show $0 deposit.

## 2. Current state (from booking-api code)
- **Deposit config is per-service** on `event_types`:
  - `deposit` (amount), `deposit_type ENUM('fixed','percent') DEFAULT 'fixed'`,
    `deposit_required TINYINT(1) DEFAULT 0` (migration 008 / `migrate.js`).
- **Tenant-level threshold exists** but is informational, not enforced:
  `deposit_required_threshold_aud` (default `100`) — surfaced in tenant snapshot/NEO context,
  not in the booking gate.
- **Deposit computation** (`jose-booking.js`):
  ```js
  function computeDeposit(svc) {
    const price = Number(svc.price) || 0;
    if (price <= 0) return { amount: 0, charge: false };
    if (!svc.deposit_required) return { amount: price, charge: true }; // pay full up-front
    const dep = Number(svc.deposit) || 0;
    // ...fixed vs percent...
  }
  ```
- **Stripe machinery exists** (`src/lib/stripe.ts` builds a Checkout session labelled
  "Booking Deposit" vs "Full Payment"; `pay-redirect.js`, `deposit-reconcile-cron.js`,
  `audit-stripe-*.js`) — but the **Stripe Connect pipeline was PAUSED on 9 May 2026**, so no
  payment is actually collected at booking time and the "Send Deposit SMS" button is disabled.
- **Admin already has a `pending_deposit` concept**: the Bookings page got a "Pending Deposit"
  chase-queue chip (PRs #488/#489, 26 May). That surfaces unpaid bookings *after the fact* — it
  does **not** block creation.

**Conclusion: the gap is server-side.** `POST /api/bookings` has no enforcement step — it
inserts `confirmed/unpaid` regardless of whether a deposit is owed.

## 3. Proposed design

### 3.1 New booking status
Use the existing `pending_deposit` concept as a real booking lifecycle state:

```
(public submit, deposit owed) -> status='pending_deposit', payment_status='unpaid'
        -> redirect customer to Stripe Checkout (deposit)
        -> on payment success (webhook/reconcile): status='confirmed', payment_status='paid'/'deposit_paid'
        -> on abandon/expiry (cron): stays 'pending_deposit'; slot released after N minutes
```

A `pending_deposit` booking is **not** a confirmed slot-holder beyond a short hold window, so
no-pay bookings can't silently occupy the calendar.

### 3.2 Server-side gate (the core fix)
In `POST /api/bookings`, after resolving the service:
1. `const { amount, charge } = computeDeposit(svc)` (extend to also honour the tenant
   `deposit_required_threshold_aud` — see Q1).
2. If `charge && amount > 0` **and** the booking source is not an approved bypass (Q3):
   - create the row as `status='pending_deposit'`, return a `payment_url` (Stripe Checkout).
   - do **not** emit the "confirmed" confirmation SMS/email yet (only a "complete your deposit"
     message, if any).
3. Else: behave as today (`confirmed`).

### 3.3 Front-end gate (defence in depth)
`BookingPage.tsx` payment step must not allow "skip" when a deposit is owed; on
`pending_deposit` response it redirects to `payment_url`. The server gate is authoritative —
the FE change is UX only.

### 3.4 Confirmation comms move to *after* payment
The confirmation SMS/email fires on the `pending_deposit -> confirmed` transition, not on row
insert. (This also means a no-pay booking sends no false "you're confirmed" message.)

## 4. OPEN PRODUCT QUESTIONS — need Kim's call (defaults proposed)

| # | Question | Recommended default |
|---|----------|---------------------|
| Q1 | Enforce on **all** services flagged `deposit_required`, or also auto-require when `price ≥ deposit_required_threshold_aud`? | **All `deposit_required` services**, AND auto-require when `price ≥ threshold` even if the per-service flag was never ticked (closes the "Elisse/Heather" hole where the flag was simply never set). |
| Q2 | What's the deposit amount default when a required service has `deposit=0`? | Fall back to tenant default / a % of price (e.g. 20%), never $0. A "required" service with $0 deposit is a misconfiguration; treat as the tenant default rather than free. |
| Q3 | Which sources keep **bypassing** deposit by design? | **Bypass:** admin-created bookings (`isAdminOverride`), staff "AGAIN" rebookings, and reschedules that carry an already-paid deposit. **Enforce:** all public self-service bookings. |
| Q4 | Hold window for an unpaid `pending_deposit` slot before it's released? | **15 minutes**, then the slot frees and the row is flagged abandoned (chase-queue). |
| Q5 | Go live behind a tenant flag first (Brisbane HIFU only), or all tenants? | **Brisbane HIFU first** behind a tenant setting, validate, then roll out. |

## 5. Dependencies & sequencing
1. **Un-pause the Stripe Connect pipeline** (`stripe_pipeline_pause_9may2026`) — hard
   prerequisite; enforcement is meaningless without a working charge path. Confirm Connect
   accounts/keys are still valid.
2. Fix fault C (SMS) in parallel so the post-payment confirmation actually reaches clients.
3. Then ship the server gate (§3.2) behind the tenant flag (Q5).

## 6. Implementation checklist (booking-api)
- [ ] `bookings.js` `POST /api/bookings`: insert `computeDeposit` gate → `pending_deposit` +
      `payment_url`; respect bypass sources (Q3) and hold window (Q4).
- [ ] `jose-booking.js` `computeDeposit`: honour tenant threshold (Q1) + non-zero fallback (Q2).
- [ ] `src/lib/stripe.ts` / `pay-redirect.js`: ensure deposit Checkout returns a URL the public
      flow can redirect to; verify success webhook flips `pending_deposit -> confirmed`.
- [ ] `deposit-reconcile-cron.js`: release/abandon slots past the hold window.
- [ ] `notifications.js`: move "confirmed" SMS/email to the payment-success transition.
- [ ] `BookingPage.tsx`: redirect to `payment_url`; no skip when deposit owed.
- [ ] Tenant flag to gate rollout (Q5).

## 7. Test / UAT
- Deposit-required service, public booking → cannot reach `confirmed` without paying; slot
  released after the hold window if unpaid.
- Paid deposit → `confirmed` + confirmation SMS/email received (verify real DLR, not just
  `status='sent'`).
- Admin-created booking → still bypasses (Q3).
- Non-deposit service → unchanged.
- Threshold-priced service with the flag *unticked* → still enforced (Q1) — this is the
  Heather/Elisse case.

_Spec by Claude · 2026-06-26 · branch `claude/book-treatment-double-booking-jjq53f`. Defaults in §4 are placeholders pending Kim's confirmation._
</content>
