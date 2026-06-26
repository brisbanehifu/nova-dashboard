# Handoff → Claude Code desktop session (repo: `booking-api`)

This web session is scoped to `nova-dashboard` and **cannot push to `brisbanehifu/booking-api`**.
Run the fixes from a **desktop Claude Code session opened inside your local `booking-api` checkout**.
Copy-paste the prompt below to start it.

---

## COPY-PASTE PROMPT

> You are working in the `brisbanehifu/booking-api` repo (the BookATreatment app: Node/Express +
> React, Railway, MySQL). A prod incident on 26 Jun 2026: new client **Heather Gettings** booked
> twice, paid $0 deposit on both, and got no confirmation SMS. The full investigation + fix plan
> live in the `nova-dashboard` repo, PR #10, as two files — read them first if you can pull that
> repo: `bug-bookatreatment-double-booking-no-deposit-no-sms-26jun2026.md` and
> `spec-r4-deposit-enforcement-26jun2026.md`. Three independent faults:
>
> **A — Silent double booking.** `bookings.js` → `normalizePhoneForDedup` strips to raw digits but
> does NOT canonicalise AU country code, so `0416…` (10 digits) ≠ `+61416…` (11 digits) and a second
> booking with a differently-formatted number is never seen as a duplicate. Also fail-open: read-then-
> insert with no DB lock/constraint. **Fix:** canonicalise all phones to E.164 (`0XXXXXXXXX` →
> `61XXXXXXXXX`, handle leading `+`) everywhere phones are saved/matched (dedup, contacts, SMS); add a
> unique index or advisory lock on (tenant_id, normalized_phone, date, time) for active statuses to
> close the race; always prompt on a same-phone same-date second booking.
>
> **B — Deposit revenue leak (R4).** `POST /api/bookings` inserts `confirmed/unpaid` with no server-
> side deposit gate; `computeDeposit` (`jose-booking.js`) only charges when `event_types.deposit_required=1`
> (default 0); Stripe Connect pipeline was PAUSED 9 May 2026. **Fix per the spec:** un-pause Stripe
> first, then gate `POST /api/bookings` → create `status='pending_deposit'` + return Stripe Checkout
> `payment_url` when a deposit is owed; confirm only on payment success; release the slot after a hold
> window; move the "confirmed" SMS/email to the payment-success transition. **Get Kim's answers to the
> 5 product questions in spec §4 before coding B.**
>
> **C — No confirmation SMS.** ClickSend was sending from an unregistered numeric sender pool →
> Telstra/Vodafone silently filter; `notification_logs.status='sent'` ≠ delivered. **Do ops checks
> first:** confirm the BRISHIFU alpha tag is ACMA-approved and active in ClickSend; confirm Railway
> `CLICKSEND_USERNAME` matches the live ClickSend username (a silent rename caused a 401 outage on
> 13 May); pull the real DLR for Heather's number. Code: normalise recipient numbers to E.164 before
> send and surface real DLR status in `notification_logs`.
>
> **Suggested order:** C (likely pure config, fastest) → A (contained code fix) → B (revenue fix,
> needs product answers + Stripe un-pause). Work on a feature branch, commit, push, open a draft PR.

---

_Created by the nova-dashboard web session · 2026-06-26 · see PR brisbanehifu/nova-dashboard#10._
</content>
