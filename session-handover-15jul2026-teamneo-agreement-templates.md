# Session Handover — TeamNEO.tech Employment/Contractor Agreement Templates
**Date:** 2026-07-15 · **Repo:** nova-dashboard · **Branch:** `claude/session-kga86k` · **PR:** [#12](https://github.com/brisbanehifu/nova-dashboard/pull/12) (draft, open, no CI configured, no review comments)

This was a cloud session. No local file access was needed and none is needed to continue — this is a pure legal-drafting/docs task, safe to pick up on desktop or cloud.

---

## ▶︎ Prompt for the next session (copy-paste)
```
Read CONTEXT.md and CLAUDE.md first. You are continuing legal-template work for Kim/Jez's
TeamNEO.tech business (Neo-Klien Pty Ltd, ABN 34 104 291 830, trading as TeamNEO.tech —
NOT "TeamNEO.tech Pty Ltd", which is not the registered entity name).

Context: Kim's employee/contractor Sai Rohith Tata quit TeamNEO.tech's NT Water project
with zero notice, and I advised her not to withhold his final 3 days' pay (wages already
earned are a protected debt under Fair Work Act 2009 (Cth) ss 323-324 — cannot be withheld
as a self-help remedy for his breach). Kim agreed to pay him. She then asked for
gold-standard employment + "connector" agreement templates for TeamNEO.tech going forward,
partly because the original Sai Rohith contract had two problems: (1) wrong legal entity
name, and (2) sham-contracting red flags (labelled him "Employee" throughout but tried to
cast him as a contractor "Key Person" via a Deed, while paying him a fixed weekly salary
with PAYG withheld and super paid).

DONE THIS SESSION (already in agreements/, committed, pushed, PR #12 open as draft):
- agreements/employment-agreement-template.md — NES-compliant employment agreement
- agreements/independent-contractor-agreement-template.md — genuine contractor agreement
  with substitution right, contractor-controlled hours, and a "is this really contracting"
  checklist to avoid repeating the sham-contracting problem

OPEN QUESTION — NOT YET RESOLVED: Kim asked for a "connector agreement" without defining
the term. I made a judgment call (her earlier AskUserQuestion prompt failed to deliver
mid-session) and built the independent contractor agreement, on the theory that "connector"
meant people like Sai Rohith placed on client engagements. It's possible she actually meant
a referral/introducer agreement (a third party who refers clients/leads to TeamNEO.tech for
a fee) — a different document entirely. CONFIRM WITH KIM which she meant before doing
anything further; if it's the referral/introducer meaning, that template still needs to be
written from scratch (nothing built for it yet).

NEXT STEPS:
1. Confirm the "connector agreement" meaning with Kim (see above).
2. Get PR #12 reviewed/merged once Kim is happy — it's a docs-only, low-risk PR.
3. Remind Kim: both templates carry "DRAFT — NOT LEGAL ADVICE" banners and need a
   Queensland employment lawyer's review before first live use (award coverage in
   particular — Schedule A of the employment template has a placeholder for the
   applicable modern award that must be confirmed per role).
4. Confirm Kim has actually paid Sai Rohith's outstanding 3 days (she said "Ok I'll pay
   him" but this happens outside the repo — nothing to verify in code, just a reminder).
```

## Files added this session (in `agreements/`)
- **`employment-agreement-template.md`** — full-time/part-time employee template. NES minimums (notice, leave, superannuation), no wage-withholding-as-remedy clause, correct entity name, restraint of trade clause, "no contracting out" clause referencing FW Act s 326.
- **`independent-contractor-agreement-template.md`** — genuine contractor template. Substitution right (clause 3.3), contractor-controlled hours, own ABN/insurance/GST, no wage-withholding-as-remedy clause, and an explicit "genuine contractor checklist" at the bottom (substitution, control, tools, integration, exclusivity, payment structure) so Kim can self-audit whether a specific engagement is really contracting before using it.

Both follow the house style of the existing `agreements/machine-sale-and-finance-agreement.md` (key-terms table, numbered clauses, execution block, schedules, "Important Note — Legal Review" footer).

## Key legal facts established this session (for context, not to re-derive)
- **Correct entity name:** Neo-Klien Pty Ltd (ABN 34 104 291 830) trading as TeamNEO.tech — same ABN as HIFU Machine Sales' legal entity per CONTEXT.md. The old Sai Rohith contract wrongly said "TeamNEO.tech Pty Ltd."
- **Wages already earned cannot be withheld** as a remedy for an employee/contractor's breach (e.g. no-notice resignation) — this is a protected debt under FW Act ss 323-324. Any claim for loss caused by the breach is a *separate* damages/debt claim, not a wage deduction.
- **The old contract's clause 13.9** ("no State or Territory Employee laws are to apply") is very likely void — parties can't contract out of NES/FW Act minimums (FW Act s 326).
- **Sham contracting risk:** the old contract's mix of "Employee" language + fixed salary + PAYG + super, alongside a Deed casting the same person as a non-employee "Key Person," is a red flag under FW Act ss 357-359. Both new templates are built to avoid repeating this — but the checklist in the contractor template only works if the *actual practice* matches the paperwork.

## PR / session state
- PR #12 is open as **draft**, base `main`, head `claude/session-kga86k`. No CI is configured on this repo, so "pending/0 checks" is expected, not a problem.
- This cloud session subscribed itself to PR #12 webhook activity. That subscription is tied to this session — if you want the **new** desktop session to handle CI/review-comment events going forward, it should call `subscribe_pr_activity` again itself (or just merge the PR directly once Kim signs off, since there's nothing to babysit).
- A scheduled hourly self-check-in was attempted but the scheduling tool call didn't get approval in this session — it was **not** successfully armed. Don't assume any automatic follow-up is happening on this PR; a fresh session should check `pull_request_read` (status/reviews) manually if picking this back up.
