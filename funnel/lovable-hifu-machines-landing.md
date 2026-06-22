# Lovable Build Spec — `/hifu-machines` Landing Page
**Goal:** a conversion page that sells HIFU machines to clinics, presents the two buying options (outright vs finance), and captures leads into the Make.com → Gmail → Notion pipeline.

**Seller:** HIFU Machine Sales · ABN 34 104 291 830 · hifumachinesales.com · jk@clinicstarterkit.com

---

## STEP 1 — Paste this into Lovable

> Add a new page at `/hifu-machines` for selling HIFU machines to beauty/skin clinics in Australia. Use a clean, premium, trustworthy aesthetic — white background, deep navy (#0B1F3A) and a warm gold accent (#C8A24B), font "Plus Jakarta Sans". Mobile-first. Sections in this order: sticky header with logo + "Book a demo" button; hero; "why own a HIFU machine" benefits; three pricing cards; a "two ways to buy" comparison (outright vs finance); trust/guarantee strip; short FAQ; lead-capture form; footer. Use the exact copy I provide below — do not invent prices or claims. Make every "Book a demo" and primary button scroll to the lead form. Keep it to one page.

Then paste the copy from STEP 2. After the page is built, do STEP 3 to wire the form.

---

## STEP 2 — Exact page copy
> **Images:** use Kim's real assets only (see `brand-assets-manifest.md`). Hero = `brand-hero.jpg`; pricing cards = `machine-13d.png`; "why HIFU" = `clinic-interior.jpg`; ROI/numbers = `deals-results.jpg`; trust band = `training-smiling.jpg`. Never use AI-generated machines.


### Hero
- **Eyebrow:** Australian-owned · 2-year warranty · onshore support
- **Headline:** Own a HIFU clinic — machine, training and marketing in one package.
- **Subhead:** Start treating clients in weeks. From **$19,995**, or finance your machine and repay it from clinic profit.
- **Primary button:** Book a 15-minute demo
- **Secondary button:** See pricing

### Why own a HIFU machine (3 benefits)
1. **High-margin treatments.** HIFU face & body treatments are premium-priced with low consumable cost per session.
2. **Everything to start.** Machine, cartridges, hands-on training and marketing support — not just a box on a bench.
3. **Backed onshore.** 2-year warranty, Australian support Mon–Sat 9–6, and a hot-swap loan machine so you're never offline.

### Pricing cards (three)
**Card 1 — 13D Package · $19,995 + GST**
- UltraTherapy 13D MPT HIFU system
- Australian support + 2-year warranty
- Hot-swap loan machine
- 1-day hands-on training
- Button: Book a demo

**Card 2 — 15D Package · $29,995 + GST**  *(label: Most popular)*
- UltraTherapy 15D MPT system
- **Bonus second cartridge set**
- Australian support + 2-year warranty
- Hot-swap loan machine
- 2-day hands-on training
- Button: Book a demo

**Card 3 — Clinic Starter Kit · $49,995 + GST**  *(label: Done-for-you)*
- 15D MPT machine + clinic fit-out guidance
- $6,000 Google Ads support
- Website + online booking setup
- Zeller EFTPOS
- 20 hours business coaching
- 3-day masterclass training
- Button: Book a demo

*Small print under cards:* All prices ex GST. Ask about our ex-demo 13D unit at $12,000 (limited availability).

### The numbers (ROI block — real figures from the proposal)
**Heading:** The machine pays for itself faster than you'd think.
- **Face treatments** retail around **$450 per 30 min**; **body** around **$500 per 30 min**.
- Your cartridge cost per treatment is only about **$40–50 (face)** or **$25–35 (body)** — roughly **5 cents a shot**.
- The **15D and Clinic Starter Kit** include **2 full sets of cartridges** — estimated to generate around **$120,000** in treatment income.
*Caption:* Figures are indicative, not a guarantee — we'll walk through your exact numbers on the demo.

### Two ways to buy (comparison block)
**Heading:** Buy outright, or let the machine pay for itself.

- **Option 1 — Pay outright.** Own it from day one. Deposit on order, balance before delivery. Title and warranty are yours immediately.
- **Option 2 — Finance with us.** Low deposit, then repay from a share of your clinic profit over roughly 12 months. We carry the machine on retained title until it's paid off, so your cash stays in your business while you build the clientele.

*Caption:* Finance is for business buyers and subject to a simple agreement. Ask us on your demo call which option suits your numbers.

### Trust / guarantee strip (icons + short text)
- ✓ 2-year warranty
- ✓ Australian onshore support (Mon–Sat 9–6)
- ✓ Hot-swap loan machine — never lose a booking
- ✓ Hands-on training at our Brisbane clinic

### FAQ (4)
- **Do I need experience?** No — training is included and you'll treat under our protocols before going solo.
- **What are the running costs?** Mainly cartridges and basic consumables; we'll walk you through the per-treatment economics on your demo.
- **How does finance work?** Low deposit, then repayments from clinic profit over ~12 months. It's for business buyers and uses a simple written agreement.
- **How fast can I start?** Most clinics are treating within a few weeks of ordering, including training.

### Lead-capture form
**Heading:** Book your 15-minute demo
**Fields:**
- Full name (text, required)
- Email (email, required)
- Phone (tel, required)
- Suburb / clinic location (text, required)
- Which package interests you? (select: 13D · 15D · Clinic Starter Kit · Not sure yet)
- How would you like to buy? (select: Pay outright · Finance it · Want to discuss)
- Message (textarea, optional)
**Submit button:** Request my demo
**Privacy line:** We'll only use your details to contact you about HIFU machines. No spam.

### Footer
HIFU Machine Sales · ABN 34 104 291 830 · hifumachinesales.com · jk@clinicstarterkit.com · 76 Skyring Terrace, Newstead QLD 4006

---

## STEP 3 — Wire the form to the pipeline

> When the lead form is submitted, POST the form data as JSON to this webhook URL: **[PASTE MAKE.COM WEBHOOK URL HERE]**. On a successful response, hide the form and show: "Thanks {first name} — pick a time that suits you:" followed by an embedded Calendly inline widget for **[PASTE CALENDLY EVENT URL]**. On error, show "Something went wrong — email jk@clinicstarterkit.com and we'll sort it."

**Payload to send** (matches the Make webhook contract in `make-com-lead-capture.md`):
```json
{ "name": "...", "email": "...", "phone": "...", "suburb": "...",
  "package": "13D|15D|Clinic Starter Kit|Not sure",
  "buy_preference": "Outright|Finance|Discuss",
  "message": "...", "source": "hifu-machines-landing" }
```


*(I generate the Make.com webhook + the Calendly demo event in the next build step, then you paste both URLs here.)*

---

## Notes for the build session
- Brand colours/fonts above are a starting point — swap to the official HIFU Machine Sales brand kit if one exists.
- Keep the page single-purpose: every CTA → the form. No nav links that leave the page.
- The two finance lines are deliberately soft (no rates/numbers) — the actual 25%/25%, ~12-month terms live in the signed **Sale & Vendor Finance agreement**, not on a public page, to avoid credit-advertising issues. Confirm wording with the solicitor before launch.
