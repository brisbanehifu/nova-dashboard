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

## 3. Proposed design (pay-inline, NO holds — per Q4)

### 3.1 Flow — deposit paid inline, no slot reservation
Per Q4 there is **no timed hold / `pending_deposit` reservation**. The deposit is collected
**inline as part of completing the booking**, and the confirmed booking row is created **only on
payment success**:

```
(public submit, deposit owed)
   -> create Stripe Checkout (deposit) and redirect customer to pay
   -> NO booking row reserving the slot yet (first-in-best-dressed)
   -> on payment success (Stripe webhook): create booking status='confirmed', payment_status='deposit_paid'
   -> on abandon: nothing was created; slot stays open for whoever pays first
```

Because nothing is reserved before payment, two people racing for the same slot resolve
first-come — the first completed payment creates the booking; the second gets "slot no longer
available" at the webhook/create step (guarded by the same active-slot check as fault A's race
guard).

### 3.2 Server-side gate (the core fix)
1. On public submit, resolve the service and `const { amount, charge } = computeDeposit(svc)`
   (keyed off the per-service `deposit_required` flag only — Q1; no threshold, no fallback — Q2).
2. If `charge && amount > 0` **and** the source is not a staff/admin bypass (Q3):
   - return a Stripe Checkout `payment_url`; **do not create a booking row yet.**
   - create the `confirmed` booking row on the **Stripe success webhook**, re-checking the slot is
     still free at that moment.
3. Else (no deposit owed, or staff/admin bypass): create `confirmed` as today.

> Note: this is authoritative server-side. The existing admin "Pending Deposit" chip still works
> for any legacy/staff-created unpaid rows — it's just no longer the public enforcement mechanism.

### 3.3 Front-end gate (defence in depth)
`BookingPage.tsx` payment step must not allow "skip" when a deposit is owed; on
`pending_deposit` response it redirects to `payment_url`. The server gate is authoritative —
the FE change is UX only.

### 3.4 Confirmation comms move to *after* payment
The confirmation SMS/email fires on the `pending_deposit -> confirmed` transition, not on row
insert. (This also means a no-pay booking sends no false "you're confirmed" message.)

## 4. PRODUCT DECISIONS (Kim, 26 Jun 2026) — LOCKED

| # | Question | **Kim's decision** | Build implication |
|---|----------|--------------------|-------------------|
| Q1 | Which services require a deposit? | **Only services explicitly ticked `deposit_required`.** No price-threshold auto-require. | Enforcement keys off the per-service flag only. ⚠️ **Operational follow-up:** any service that should take a deposit MUST be ticked, or it stays free. See §4.1. |
| Q2 | Deposit amount when a required service has `deposit=0`? | **$0** — no auto-fallback. Charge exactly what's configured. | No % fallback logic. ⚠️ A ticked service with `deposit=0` charges nothing — treat as a config error to catch, not a code path. See §4.1. |
| Q3 | Which sources bypass deposit by design? | **Staff / admin rebookings and admin-created bookings bypass.** | Skip the gate when `isAdminOverride` / staff-created. **Enforce only on public self-service bookings.** |
| Q4 | Hold window for an unpaid slot before release? | **NO holds.** Holds were tried before and were problematic — removed. **First-in-best-dressed.** | **No `pending_deposit` slot-reservation/timed-release.** Deposit is paid **inline** during booking; the booking is only created/confirmed on payment success. No unpaid booking sits reserving a slot. Concurrent attempts on the same slot resolve first-come (first completed payment wins; the other gets "slot taken"). |
| Q5 | Roll out Brisbane-first or all clinics? | **All clinics.** | No tenant feature-flag gating — ship to all tenants at once. |

### 4.1 ⚠️ Consequence of Q1 + Q2 (read this)
Because enforcement only bites on services that are **both ticked AND have a non-zero deposit
amount**, the fix alone will NOT stop a $0 booking on a service that was never ticked — which may
be exactly what happened with Heather. **Before/alongside the code fix, audit `event_types`:**
make sure every service that should take a deposit has `deposit_required=1` AND a non-zero
`deposit`. (`scripts/audit-stripe-wiring.js` already reports per-tenant deposit config.) Otherwise
the revenue leak persists by configuration, not by code.

## 5. Dependencies & sequencing
1. **Un-pause the Stripe Connect pipeline** (`stripe_pipeline_pause_9may2026`) — hard
   prerequisite; enforcement is meaningless without a working charge path. Confirm Connect
   accounts/keys are still valid.
2. Fix fault C (SMS) in parallel so the post-payment confirmation actually reaches clients.
3. Audit service deposit config (§4.1).
4. Then ship the server gate (§3.2) to **all clinics** (Q5 — no tenant flag).

## 6. Implementation checklist (booking-api)
- [ ] **Config audit FIRST (§4.1):** ensure every deposit-taking service has `deposit_required=1`
      AND a non-zero `deposit` (run `scripts/audit-stripe-wiring.js`). Without this the code fix
      changes nothing for un-ticked services.
- [ ] `bookings.js` `POST /api/bookings`: when `computeDeposit` says a deposit is owed and the
      source isn't a staff/admin bypass (Q3) → return Stripe Checkout `payment_url`, do NOT create
      a booking row yet (Q4: no holds).
- [ ] `jose-booking.js` `computeDeposit`: keep keyed off `deposit_required` only (Q1); charge the
      configured amount exactly, no fallback (Q2).
- [ ] `src/lib/stripe.ts` / `pay-redirect.js`: deposit Checkout returns a `payment_url`; the
      **success webhook creates the `confirmed` booking**, re-checking the slot is still free
      (first-in-best-dressed) using the same active-slot guard as fault A.
- [ ] `notifications.js`: emit the "confirmed" SMS/email on the payment-success/create transition.
- [ ] `BookingPage.tsx`: redirect to `payment_url`; no "skip payment" path when a deposit is owed.
- [ ] Ship to **all clinics** — no tenant feature flag (Q5).
- [ ] **Prerequisite:** Stripe Connect pipeline un-paused (`stripe_pipeline_pause_9may2026`).

## 7. Test / UAT
- Deposit-required (ticked, non-zero) service, public booking → no booking is created until the
  deposit is paid; abandoning payment leaves the slot open (no held/ghost booking — Q4).
- Paid deposit → `confirmed` + confirmation SMS/email received (verify real DLR, not just
  `status='sent'`).
- Two customers race the same slot → first completed payment wins; the second gets "slot taken".
- Staff/admin-created or rebooking → still bypasses, no deposit required (Q3).
- Non-deposit service (not ticked) → unchanged; **still books for $0** (Q1/Q2) — by design, so
  confirm via §4.1 audit that the right services are actually ticked.
- All clinics behave the same (Q5).

_Spec by Claude · 2026-06-26 · branch `claude/book-treatment-double-booking-jjq53f`. Defaults in §4 are placeholders pending Kim's confirmation._
</content>
