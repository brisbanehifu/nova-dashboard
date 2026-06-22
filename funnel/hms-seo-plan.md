# HIFU Machine Sales — SEO Plan (hifumachinesales.com)
Goal: rank for **buyers searching to purchase a HIFU machine / start a HIFU clinic in Australia**, and feed organic traffic into the same funnel as the ads (landing page → lead form → MailerLite → demo). Complements Google Ads + Facebook/Zeely; SEO is the compounding, lower-cost channel.

**Audience & intent:** clinic owners, beauty therapists and aspiring clinic operators in AU researching machines to buy — high commercial intent, low-to-medium search volume, low competition (a winnable niche).

---

## 1. Target keywords
**Primary (commercial, build dedicated pages):**
- HIFU machine for sale Australia
- buy HIFU machine / HIFU machine price (cost) Australia
- HIFU machine packages
- MPT HIFU machine / UltraTherapy HIFU machine
- HIFU machine for clinics

**Secondary:**
- HIFU machine training Australia
- HIFU machine finance / payment plan
- 13D HIFU machine · 15D HIFU machine
- HIFU machine warranty / support Australia
- best HIFU machine Australia

**Long-tail / content (buyer-education, build blog posts):**
- how much does a HIFU machine cost
- how to start a HIFU clinic in Australia
- is a HIFU machine a good investment / HIFU machine ROI
- HIFU machine vs [Ultherapy / RF / laser]
- HIFU cartridge cost per treatment
- HIFU machine running costs
- do you need a licence to do HIFU in Australia (Qld)

## 2. Site architecture (pages to build on the Lovable site)
- `/hifu-machines` — the conversion landing page (already specced). **Primary target:** "HIFU machine for sale Australia".
- `/hifu-machines/13d`, `/15d`, `/clinic-starter-kit` — one page per package (price, inclusions, the `machine-13d.png` photo, demo CTA). Targets model + package keywords.
- `/hifu-machine-finance` — the outright-vs-finance explainer. Targets "HIFU machine finance".
- `/hifu-training` — masterclass training detail. Targets "HIFU machine training Australia".
- `/blog` (or `/resources`) — buyer-education hub feeding the above.

## 3. On-page essentials (every page)
- One clear **H1** with the primary keyword; logical H2/H3.
- **Title tag** ≤ 60 chars (e.g. "HIFU Machine for Sale Australia | Packages from $19,995 — HIFU Machine Sales").
- **Meta description** ≤ 155 chars with price + CTA.
- Descriptive **URLs**, **alt text** on every image (use the real asset filenames/descriptions), internal links between package pages and blog posts.
- A visible **price** ($19,995 from) and **demo CTA** above the fold — helps both conversion and "price" intent.
- **Schema:** `Product` + `Offer` (price, currency AUD) on package pages; `FAQPage` on the landing FAQ; `Organization` sitewide.

## 4. Content plan (publish ~2/month to start)
Each post = ~1,000–1,500 words, answers a real buyer question, ends with a demo CTA, internally links to the relevant package page.
1. "How much does a HIFU machine cost in Australia? (2026 price guide)" — captures the big "price" query; embed your package table.
2. "How to start a HIFU clinic in Australia — the complete checklist" — top-of-funnel, links to Clinic Starter Kit.
3. "Is a HIFU machine a good investment? Real ROI numbers" — use the deals.md economics ($450/$500 RRP, ~5c/shot, $120K cartridge yield).
4. "HIFU vs Ultherapy vs RF vs laser — which machine should your clinic buy?"
5. "HIFU machine running costs: cartridges, training and support explained."
6. "Do you need a licence to perform HIFU in Queensland?" — authority + local intent.

## 5. Technical SEO
- Verify the domain in **Google Search Console** (you already control DNS) + submit an **XML sitemap**.
- Fast mobile load (Lovable is React — watch image weight; compress the brand photos), HTTPS, clean canonical tags.
- Make sure the Lovable SPA renders crawlable content (SSR/prerender or static so Google sees the copy, not an empty shell) — **check this early**, it's the #1 SPA SEO trap.
- No-index the `/admin/*` and thank-you pages.

## 6. Local / Google Business Profile
- The training happens at the **Brisbane clinic** — a GBP for "HIFU Machine Sales" (or training studio) helps "HIFU machine training Brisbane/Australia" and adds trust.
- Consistent **NAP** (name/address/phone — 76 Skyring Tce, Newstead; 0410 550 232) across the site footer + any directories.

## 7. Authority & links (slow, ongoing)
- List in AU beauty-industry directories and supplier listings.
- Guest articles / interviews in aesthetics & salon-business publications.
- The G2/Capterra + industry presence from BookATreatment can cross-link where relevant.
- Encourage buyer testimonials/case studies (also great conversion content).

## 8. 30-day quick wins
1. Ship `/hifu-machines` with proper title/meta/H1 + Product schema.
2. Set up **Google Search Console** + sitemap; confirm the page is indexable (not an empty SPA).
3. Publish posts #1 ("price guide") and #3 ("ROI") — highest commercial intent.
4. Add internal links from posts → package pages → demo CTA.
5. Create the GBP and add the Newstead NAP to the footer.

## 9. Measure
- Search Console: impressions/clicks/position for the primary keywords (monthly).
- GA4 (or Lovable analytics): organic sessions → lead-form submissions (tie to the `source` field in the lead payload — set organic leads to `source=organic`).
- North-star: **demo bookings from organic**.

> Keep this aligned with the ads/landing copy in `go-to-market-content.md` and the package facts in `deals.md` — same numbers everywhere.
