# CONTEXT — Read this FIRST before any work

Canonical operating facts for Kim/Jez's businesses. If something here conflicts with an assumption, **this file wins**. Keep it updated when setup changes.

_Last verified: 2026-06-22._

---

## Company & people
- **Legal entity:** Neo-Klien Pty Ltd — **ABN 34 104 291 830**. Holds the ABN and trades under multiple business names.
- **Business names:** **HIFU Machine Sales** (machine sales), **Brisbane HIFU Clinic**, plus others.
- **Directors / contacts:** Kim Klein (KK) +61 416 248 639 · Jeremy Small (JS, "Jez") +61 410 550 232.
- **Primary Workspace user:** Jez Klein `<jk@startupbusiness4sale.com>` — this is the main mailbox where everything lives.

## Email & domains (Google Workspace — NOT Titan)
- ⚠️ **Email is on Google Workspace.** Titan was fully migrated OFF (painful). **Do not reference Titan.**
- **Primary domain:** `startupbusiness4sale.com` (Gmail activated). Main inbox + lead-alert inbox = `jk@startupbusiness4sale.com`.
- **User alias domain:** `clinicstarterkit.com` → `jk@clinicstarterkit.com` lands in the jk@startupbusiness4sale mailbox.
- **Secondary domains:** `bookatreatment.ai`, `teamneo.tech`, and **`hifumachinesales.com`** (added 2026-06-22).
- **`hifumachinesales.com` email (set up 2026-06-22):** MX → `smtp.google.com`; DKIM added; SPF should be `v=spf1 include:_spf.google.com ~all`; `jk@hifumachinesales.com` is an **alias on the jk user** — live & tested ✅.
- **DNS:** managed in **Cloudflare**. Website runs on **Lovable** (A record 185.158.133.1; `notify` subdomain delegated to lovable.cloud).
- **Old gmail:** `gm.teamneo@gmail.com` (personal/agency). Forwarding from startupbusiness4sale to it was **disabled** (was bouncing forwarded spam).

## Tool stack
- **Email marketing:** **MailerLite** (account "HIFU Machine Sales", under jk@startupbusiness4sale.com). 3-email nurture = **`HMS-Email-Sequence`**; lead group = `HIFU Machine Leads`.
- **Booking:** **BookATreatment** app — demo link **https://app.bookatreatment.ai/book/mpt-demo-1hr**. ⚠️ **Not Calendly** (Calendly is no longer used).
- **Automation:** **Make.com**. ⚠️ Make API can't be driven from remote web sessions (connector approval gate) — build in the Make UI or a desktop session.
- **Website builder:** **Lovable**.
- **Leads:** Lovable form → saved to `/admin/leads` + alert email to `jk@startupbusiness4sale.com`.
- **Ads:** Google Ads; Facebook via **Zeely AI**.
- **Design:** **Canva** (brand kit: "HIFU Machine Sales"). **SMS:** ClickSend.

## Products / deals
Source of truth: **`funnel/deals.md`**. Summary (all ex GST): **13D $19,995 · 15D $29,995 · Clinic Starter Kit $49,995 · ex-demo 13D $12,000.** All include 2-yr warranty, AU support (Mon–Sat 9–6), hot-swap loan machine.

## Hard rules (mistakes to never repeat)
1. **Marketing shows "HIFU Machine Sales" only** — never "Neo-Klien" (the legal entity appears *only* in signed agreements).
2. **Email = Google Workspace.** Titan is dead.
3. **Booking = BookATreatment**, not Calendly.
4. **Never generate machine/clinic imagery** — use Kim's real photos (`funnel/brand-assets-manifest.md`).
5. **Make.com** can't be built via API from remote web sessions.

## Repo map
- `funnel/` — go-to-market: `deals.md`, `lovable-hifu-machines-landing.md`, `go-to-market-content.md` (emails + Facebook/Zeely), `make-com-lead-capture.md`, `mailerlite-and-make-setup.md`, `go-live-checklist.md`, `brand-assets-manifest.md`, `images/`.
- `agreements/` — `machine-sale-and-finance-agreement.md` (the Zena contractor agreement is held by Kim as a Word doc).
- `session-handover-*.html` — recent session records; skim the latest for in-flight context.
