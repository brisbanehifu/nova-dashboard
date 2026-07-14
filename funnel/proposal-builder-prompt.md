# Prompt — Generate the HIFU Machine Sales proposal as HTML ("design as code", no Canva)

Paste the block below into Claude (or ask me directly). It rebuilds your Starter Packages proposal as a single, branded, print-to-PDF HTML file — with the 5 typo fixes baked in — and outputs sliceable sections for socials + automation. All data is from `funnel/deals.md` (source of truth).

---

```
🔒 GOLDEN RULE — THE MACHINES: Never recreate, redraw, restyle, "improve", reinterpret or
AI-generate the HIFU machines or clinic photos. Embed Kim's ACTUAL photo files exactly as-is
(machine is always machine-13d.png / 7/8/9.jpg). Zero drift on the machine look. If a photo
is missing, use a clearly-marked placeholder and ASK — never invent or substitute a machine.

You are designing a premium B2B sales proposal for HIFU Machine Sales (a business of
Neo-Klien Pty Ltd, ABN 34 104 291 830) that sells HIFU machines to Australian clinics.
Output a SINGLE responsive HTML file (inline CSS, no external deps) that prints cleanly to
A4 PDF (use CSS @page + page-break-after between sections). Also output, separately, a set
of square (1080×1080) and portrait (1080×1350) "social tile" HTML snippets reusing the same
styles, one per key selling point — so the proposal and the socials share one design system.

BRAND / LOOK:
- Premium, clean, trustworthy. White background, deep navy #0B1F3A, warm gold #C8A24B accents,
  font "Plus Jakarta Sans". Generous whitespace. Subtle section dividers.
- Use ONLY real brand photos from funnel/images/ (see funnel/brand-assets-manifest.md):
  cover/hero = brand-hero.jpg or clinic-interior.jpg; machine shots = machine-13d.png;
  training = training-smiling.jpg; results = deals-results.jpg. NEVER generate or invent a
  machine image. Reference images by relative path (funnel/images/<file>) with good alt text.
- Footer on every page: HIFU Machine Sales · ABN 34 104 291 830 · hifumachinesales.com ·
  jk@hifumachinesales.com · 0410 550 232. Marketing shows "HIFU Machine Sales" ONLY — never
  "Neo-Klien".

STRUCTURE (mirror the current proposal):
1. COVER — hero photo, title "HIFU Starter Kits Proposal", brand lockup.
2. WELCOME letter — quote: "We welcome you into our HIFU community and can't wait to watch
   your business flourish. We truly hope it brings you the same freedom, profits, and lifestyle
   it's given us." — signed Jeremy Small & Kim Klein, Directors. Contacts: JS +61 410 550 232,
   KK +61 416 248 639, jk@clinicstarterkit.com, hifumachinesales.com.
3. CHOOSE YOUR PACKAGE — comparison table of all three (price, best-for, what's included, training).
4. One DETAIL page per package (use exact data below).
5. ROI / "the numbers" — RRP Face $450 / Body $500 per 30min; cartridge cost ~5c/shot
   ($40–50 face, $25–35 body per treatment); 10,000 shots/cartridge; the 15D & Clinic Starter
   Kit include 2 full sets of cartridges (~$120K estimated income). Mark figures "indicative".
6. TWO WAYS TO BUY — Option 1 Pay Outright; Option 2 Finance (low deposit, repay from clinic
   profit over ~12 months, seller retains title until paid). Keep finance wording soft (no rates).
7. NEXT STEP — "Book a demo" button → https://app.bookatreatment.ai/book/mpt-demo-1hr.

EXACT PACKAGE DATA (all prices ex GST):
- Option 1 — CLINIC STARTER KIT $49,995: UltraTherapy 15D MPT machine (MMFU = Micro and Macro
  Focused Ultrasound); 2-yr warranty; AU support Mon–Sat 9am–6pm; hot-swap loan machine;
  cartridges Face (7: standard 4.5+3+2+1.5mm, probe 4.5+3+1.5mm) + Body (3: 13+9+6mm); BONUS 2
  full cartridge sets (~$120K); 10,000 shots/cartridge; $500/cartridge. INCLUDED: 3-day
  Masterclass training (Brisbane, up to 3 ppl); Booking App; Website build + domain + 6mo
  hosting; Zeller EFTPOS (12mo warranty) + Afterpay/Zip; 20hrs business coaching; $6,000 Google
  Ads + 6mo setup/tuning; clinic fit-out (treatment table + display shelving).
- Option 2 — 15D PACKAGE $29,995: UltraTherapy 15D MPT (MMFU); 2-yr warranty; AU support;
  hot-swap loan; BONUS 2 full cartridge sets (~$120K); cartridges as above; 2-DAY Masterclass
  training (up to 3 ppl, Brisbane).
- Option 3 — 13D PACKAGE $19,995: UltraTherapy 13D MPT (MMFU); 2-yr warranty; AU support;
  hot-swap loan; cartridges as above; NO bonus sets; 1-DAY Masterclass training (up to 3 ppl).
- Also mention: ex-demo 13D available at $12,000 (limited).

FIXES TO APPLY (these were wrong in the old Canva version — get them right):
1. Spell "AUSTRALIA" correctly (old cover said "AUSTALIA").
2. Show full prices "$19,995" and "$29,995" (old quick-guide truncated to $19,99 / $29,99).
3. 13D training is "1 day" (old page title wrongly said "2 days").
4. "Micro and MACRO Focused Ultrasound" (old said "Maro").
5. Heading grammar: "1 day" / "2 days" / "3 days" (no "1 days").

OUTPUT: (a) the full proposal HTML; (b) 5–6 social-tile snippets (square + portrait) for:
"Own a HIFU clinic from $19,995", "Two ways to buy", "RRP $450/30min · ~5c a shot",
"2-yr warranty + AU support + loan machine", "3-day Masterclass training included",
"Book a demo". Keep all copy and numbers identical to the proposal.
```

---

## Notes
- Save generated proposals to `funnel/proposals/` and social tiles to `funnel/social/` so they're versioned and reusable by the automation.
- For per-lead automation, the same template can be data-merged from `deals.md` (e.g. auto-fill the buyer's name + chosen package, render to PDF, attach in the MailerLite/Make flow).
- The 205-page **Australian HIFU Buyers Guide** is a separate lead-magnet rebuild — bigger job; tackle on its own once the proposal template is locked.
