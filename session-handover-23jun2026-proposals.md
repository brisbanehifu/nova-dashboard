# Session Handover — Proposals & Socials as HTML ("design as code")
**Date:** 2026-06-23 · **Repo:** nova-dashboard · **Branch:** `claude/business-opportunities-review-sg1q6f`
**⚠️ Run the next session in DESKTOP Claude Code** so it can read Kim's local image files directly (this is a file-access task). Read `CONTEXT.md` + `CLAUDE.md` first.

---

## ▶︎ Prompt for the next session (copy-paste)
```
Read CONTEXT.md and CLAUDE.md first. You are continuing the HIFU Machine Sales work for
Kim/Jez. GOAL THIS SESSION: replace the slow Canva workflow by rebuilding the sales
proposal (and matching social tiles) as "design as code" — clean, branded HTML that
prints to PDF and can be carved up for socials + automation. Use Kim's REAL photos, never
generated machine images.

Run locally (desktop) so you can read the images. Steps:
1. Copy Kim's brand photos from
   C:\Users\kimkl\Documents\Claude\HMS-Email-Sequence\images\
   into the repo at  <repo>\funnel\images\  (machine-13d.png, brand-hero.jpg,
   clinic-interior.jpg, clinic-owner-portrait.jpg, before-after.png, deals-hero.jpg,
   deals-results.jpg, training-smiling.jpg, 7.jpg, 8.jpg, 9.jpg). Commit them.
2. Build  funnel/proposals/hifu-starter-packages.html  using the spec in
   funnel/proposal-builder-prompt.md, the data in funnel/deals.md, and the image map in
   funnel/brand-assets-manifest.md. Print-to-PDF clean (A4, page breaks).
3. Build  funnel/social/  tiles (square 1080x1080 + portrait 1080x1350) reusing the same
   design system: "Own a HIFU clinic from $19,995", "Two ways to buy", "$450/30min ~5c a
   shot", "2yr warranty + AU support + loan machine", "3-day Masterclass training",
   "Book a demo".
4. Apply the 5 fixes (below). Render a PDF of the proposal for Kim to review.
5. Commit + open a draft PR.

HARD RULES (CONTEXT.md): 🔒 GOLDEN RULE — never recreate/redraw/restyle/"improve" or
AI-generate the machines or clinic photos; embed Kim's actual photo files exactly as-is,
zero drift (missing photo = placeholder + ASK). email=Google Workspace (Titan dead);
booking=BookATreatment (demo: https://app.bookatreatment.ai/book/mpt-demo-1hr, not Calendly);
marketing shows "HIFU Machine Sales" only (never Neo-Klien).
```

## The 5 fixes (were wrong in the old Canva proposal)
1. "AUSTRALIA" (cover said "AUSTALIA").
2. Full prices "$19,995" / "$29,995" (quick-guide truncated to $19,99 / $29,99).
3. 13D training = **1 day** (page title wrongly said "2 days").
4. "Micro and **MACRO** Focused Ultrasound" (said "Maro").
5. Heading grammar "1 day / 2 days / 3 days".

## What's already in the repo (in main)
- `funnel/proposal-builder-prompt.md` — the full HTML proposal spec (brand, structure, data, fixes, social tiles).
- `funnel/deals.md` — source of truth for all package data + economics.
- `funnel/brand-assets-manifest.md` — which photo goes where.
- `funnel/images/` — currently only README.md; **images still need adding** (step 1 above).
- Rest of funnel/: landing spec, email sequence, Facebook/Zeely pack, Make recipe, MailerLite setup, go-live checklist, HMS SEO plan.
- `CONTEXT.md` + `CLAUDE.md` — canonical facts.

## Image source (local)
`C:\Users\kimkl\Documents\Claude\HMS-Email-Sequence\images\` — 11 brand photos. The HTML proposal references them as `funnel/images/<file>`.

## After the proposal: bigger asset (separate job)
The 205-page **Australian HIFU Buyers Guide** (lead magnet) — rebuild as HTML later, once the proposal template is locked.

## Still-open funnel items (not this session, but on the board)
MailerLite group + fields + API key · Make.com 4-module scenario (build in UI, API blocked on web) · Gmail send-as + SPF=Google · ship `/hifu-machines` on Lovable · HMS SEO execution. Full board: `session-handover-22jun2026.html`.
