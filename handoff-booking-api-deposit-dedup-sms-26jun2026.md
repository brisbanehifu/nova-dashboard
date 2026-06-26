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
> (default 0); Stripe Connect pipeline was PAUSED 9 May 2026. **Kim's product decisions are LOCKED
> (spec §4):** (1) enforce only on services explicitly ticked `deposit_required` — no price
> threshold; (2) charge exactly the configured amount, no fallback (a ticked $0 service charges $0);
> (3) staff/admin rebookings & admin-created bookings bypass, enforce on public only; (4) **NO holds
> — pay inline, first-in-best-dressed:** do NOT reserve a slot or create a `pending_deposit` row —
> return a Stripe Checkout `payment_url` and create the `confirmed` booking ONLY on the payment-success
> webhook (re-check slot free then); (5) ship to all clinics, no tenant flag. **Prerequisites:**
> un-pause Stripe first, AND audit `event_types` so the services that should take a deposit are
> actually ticked with a non-zero amount (spec §4.1) — otherwise the leak persists by config. Move
> the "confirmed" SMS/email to the payment-success transition.
>
> **C — No confirmation SMS.** UPDATE 26 Jun (Kim): the **BRISHIFU ACMA alpha tag is now APPROVED**,
> so the sender-registration cause is resolved — the most likely remaining cause is the **Railway
> `CLICKSEND_USERNAME` env var being wrong**. On 13 May a silent ClickSend rename of the master
> `api_username` (`Brisbane.HIFU.clinic@gmail.com` → `BrisbaneHifu`) made every send return **401**.
> **Do this first:** in Railway (service `web`), confirm `CLICKSEND_USERNAME` matches the *current*
> live ClickSend API username exactly; fix + redeploy if not (`railway variables --set
> CLICKSEND_USERNAME=<correct> --service web` then `railway redeploy --service web --yes`). Then pull
> the real DLR for Heather's number to confirm delivery (don't trust `status='sent'`). Code (lower
> priority now): normalise recipient numbers to E.164 before send and surface real DLR status in
> `notification_logs`.
>
> **Suggested order:** C (likely pure config, fastest) → A (contained code fix) → B (revenue fix,
> needs product answers + Stripe un-pause). Work on a feature branch, commit, push, open a draft PR.

---

_Created by the nova-dashboard web session · 2026-06-26 · see PR brisbanehifu/nova-dashboard#10._
</content>
