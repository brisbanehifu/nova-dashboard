# HIFU Machine Sales Funnel — Go-Live Checklist
One pass, top to bottom, gets the funnel live. ~30–40 min total. Tick as you go.

## 1. MailerLite (~10 min)
- [ ] Create a group: **`HIFU Machine Leads`**.
- [ ] Create custom fields: `phone`, `suburb`, `package`, `buy_preference`.
- [ ] Open your **`HMS-Email-Sequence`** automation → set the trigger to **"When subscriber joins group → HIFU Machine Leads"**.
- [ ] Confirm the 3 emails are loaded (copy in `go-to-market-content.md`) and the images are uploaded inside MailerLite (use `brand-hero.jpg`, `machine-13d.png`, `deals-hero.jpg`, `clinic-owner-portrait.jpg` per the manifest).
- [ ] Settings → Integrations → **Developer API** → generate an **API key** (paste into Make, Module 2).

## 2. Calendly (~5 min)
- [ ] Create a 15-min event type: **"HIFU Machine Demo (Online or In-Person)"**.
- [ ] Set your availability + Zoom/phone. Copy the **event link**.

## 3. Make.com — build the spine (~15 min, recipe in `make-com-lead-capture.md`)
- [ ] Webhooks → **Custom webhook** `HIFU lead form` → copy URL.
- [ ] **MailerLite → Create/Update Subscriber** → map fields → add to group `HIFU Machine Leads`.
- [ ] **Email/Gmail → Send** alert to `jk@startupbusiness4sale.com` (or your live Gmail).
- [ ] **Webhooks → Webhook response** → 200 + `{ "calendly": "<your Calendly link>" }`.
- [ ] Turn scenario **ON**, scheduling = **Immediately**.

## 4. Lovable (~5 min)
- [ ] Build `/hifu-machines` from `lovable-hifu-machines-landing.md` (STEP 1 + 2).
- [ ] Upload the real photos (per manifest) — never the AI machine images.
- [ ] STEP 3: paste the **Make webhook URL** + **Calendly link** into the form.
- [ ] (Recommended) add the **Meta Pixel** so Facebook/Zeely can optimise + retarget.

## 5. Images (one-time)
- [ ] Copy `HMS-Email-Sequence/images` → `funnel/images/` in this repo (or upload to each tool directly). Source of truth: `brand-assets-manifest.md`.

## 6. Test the whole chain
- [ ] Submit a real test from the live `/hifu-machines` form.
- [ ] ✅ Lead lands in MailerLite (right group) → Email 1 arrives.
- [ ] ✅ Alert email hits your inbox.
- [ ] ✅ Form shows the Calendly "book a time" step.
- [ ] Then point **Zeely/Facebook ads** (content in `go-to-market-content.md`) at the live page.

## 7. Proposal polish (parallel, in Canva)
- [ ] Fix the 5 typos in `deals.md` (AUSTALIA, truncated prices, 13D "2 days", "Maro"→Macro, day grammar).

---
**Confirm before launch:** Is `jk@startupbusiness4sale.com` actually monitored? If not, swap the alert address to a Gmail you check daily — a lead that sits unread is a lost sale.
