# SEO Autopilot — Product Spec (working name)

_Draft v0.1 · 2026-07-05 · owner: Jez/Kim · status: SCOPING — needs sign-off on the 4 decisions below before build starts._

## 0. What this is (one paragraph)
We currently pay **AutoSEO** (getautoseo.com, ~US$79–199/mo per plan) to run our blogs on autopilot: their AI researches Google, writes one SEO article a day, publishes it to the site, tracks keyword rankings, and (claims to) build backlinks. This spec is for **building our own version of that engine** — first to run our own sites (HIFU Machine Sales `hifumachinesales.com`, Brisbane HIFU `brisbanehifu.com.au`) for free, then to **package and resell it** as a SaaS the same way we sell BookATreatment. It reuses the muscle we already have: Supabase, Claude, Make, and a proven "sell-a-tool-to-clinics" playbook.

---

## ⚠️ 1. Four decisions I need from you (I've assumed a default for each so the spec is buildable — change any of them)

I tried to ask these interactively but the session couldn't take the prompt, so I picked the recommended default and wrote the rest of the doc around it. Tell me to flip any of these and I'll re-scope.

| # | Decision | **Assumed default** | Alternatives |
|---|----------|---------------------|--------------|
| **D1** | How ambitious is build #1? | **Our sites first, architected to go multi-tenant later.** Fastest to value, lowest risk, and we dogfood before we sell. | (a) Full multi-tenant SaaS from day one; (b) minimal — just replace what we pay for, no product ambitions. |
| **D2** | Where do articles publish? | **Our own sites first** (Lovable/Hostinger) **+ a WordPress plugin** as the resale beachhead (most SMB blogs are WP, same as AutoSEO). | Add Webflow/Shopify/headless API; or "export Markdown only" for MVP. |
| **D3** | Which capabilities first? | **Article engine + auto-publish/scheduling + rank tracking.** Backlink-building **deferred** (riskiest, weakest part of these tools — see §9). | Pull backlinks forward; or drop rank tracking from MVP. |
| **D4** | AI writing engine | **Claude API** (Sonnet for drafts, Opus for the research/outline pass). Best quality + brand-safety, we control the prompt and the per-article cost. | Cheapest-good-enough model to fatten resale margin; or multi-model. |

Everything below assumes **D1=own-sites-first, D2=our-sites+WordPress, D3=engine+publish+tracking, D4=Claude.**

---

## 2. Goals & non-goals

**Goals**
1. **Kill the AutoSEO subscription** for our own sites — same output (a good SEO article on a schedule, published, tracked) at API cost only.
2. **On-brand, on-topic** content that actually feeds our funnel (organic → landing → lead form → MailerLite → BAT demo), not generic filler.
3. **Sellable**: a clinic/SMB can connect their site, pick their keywords, and get daily articles — a productised recurring-revenue tool, priced under AutoSEO.

**Non-goals (v1)**
- Not a full SEMrush/Ahrefs replacement (no backlink-graph crawler, no site-audit suite). We already have a live on-page audit workflow (`seo-fastest-wins-brisbanehifu.html`) and pull real keywords from **Google Ads Search Terms** + **Search Console** — v1 leans on those, not a bought keyword database.
- Not automated black-hat link building (§9).
- Not image generation (see §3 — hard rule).

---

## 🔒 3. Golden Rule constraint (non-negotiable, product-wide)
Per `CONTEXT.md` and `funnel/brand-assets-manifest.md`: **the engine must NEVER generate, redraw, or "tidy" the HIFU machines or Kim's clinic photos.** For *our* sites, article images may only be selected from the approved asset manifest (`machine-13d.png`, `brand-hero.jpg`, etc.) or left blank with a marked placeholder — never AI-generated. This becomes a first-class product feature, not just our rule: **every tenant gets a locked "Approved Image Library"** and the engine can only insert images from it (or none). This is genuinely a selling point for regulated/aesthetic clients who can't have AI inventing product shots. Default image behaviour for a new tenant = **text-only until they upload an approved library.**

---

## 4. Personas
- **Operator (us):** Kim/Jez. Wants "set the keywords once, approve or auto-publish, watch rankings climb." Near-zero daily effort.
- **Customer (resale):** a clinic owner / SMB marketer. Wants the same, plus a dead-simple connect-your-site step and a dashboard that shows "look, traffic went up." Low technical skill — the WordPress plugin + a hosted dashboard is the whole UX.

---

## 5. The core engine — daily pipeline
This is the heart of the product. One scheduled run per site per day (cron/queue):

```
[1] TOPIC SELECTION
    ├─ pull the site's keyword list + intent tags (commercial / educational / local)
    ├─ pull recent GSC queries (rank 11–30 "striking distance" = highest ROI)  ← reuse existing method
    ├─ pull Google Ads Search Terms for real buyer language (our proven source)
    └─ dedupe against already-published topics → pick today's target keyword + angle

[2] SERP RESEARCH
    ├─ fetch top ~10 results for the target query (SerpAPI or similar)
    ├─ extract: what the ranking pages cover, headings, questions (PAA), gaps
    └─ build a research brief (Opus pass)

[3] DRAFT (Claude, Sonnet)
    ├─ system prompt = tenant brand kit (voice, entity rules, banned claims, CTA, internal-link map)
    ├─ write 1,000–1,500 word article to brief: H1 w/ keyword, logical H2/H3,
    │  title ≤60 chars, meta ≤155 chars, schema hints, internal links, demo CTA
    └─ select image(s) ONLY from the tenant's Approved Image Library (or none)

[4] BRAND & COMPLIANCE GATE  ← our differentiator
    ├─ entity rules (e.g. "HIFU Machine Sales" not "Neo-Klien"; correct prices from deals.md)
    ├─ medical/therapeutic-claims filter (TGA — see §10). Flag/soft-block risky claims.
    ├─ no-AI-image assertion; factual/price check against source of truth
    └─ plagiarism / near-duplicate check

[5] PUBLISH
    ├─ auto-publish OR queue for 1-click approval (per-tenant setting)
    ├─ push via the site connector (WordPress REST plugin / Lovable feed / export)
    └─ ping sitemap + (optional) Search Console URL-inspection submit

[6] TRACK
    └─ register the target keyword in rank tracking; log the published URL
```

**Approval modes (per tenant):** `auto` (publish immediately — AutoSEO's default) · `review` (drops into an approval queue like our existing `email-approvals` pattern) · `off`. We should run our own sites in `review` for the first ~2 weeks, then `auto`.

---

## 6. Publishing connectors (D2)
1. **WordPress plugin** — the resale beachhead. A thin plugin (mirrors AutoSEO's `getautoseo-ai-content-publisher`) that authenticates to our API and creates posts via the WP REST API. Most SMB/clinic blogs are WP → widest market.
2. **Our sites (Lovable / Hostinger).** Brisbane HIFU is **Hostinger Website Builder** (not WP — confirmed in the SEO file), and HMS is **Lovable (React SPA)**. Neither takes a WP plugin, so:
   - Lovable: publish into a `posts` table the site reads (headless), or a build-time content feed. **Watch the SPA-SEO trap** (`hms-seo-plan.md` §5) — content must be server-rendered/prerendered so Google sees it.
   - Hostinger: no clean API → **v1 = generate + export** (Markdown/HTML) for paste-in, OR migrate the blog to a headless feed. Flag: Hostinger is the awkward one; decide per-site.
3. **Headless API + export** — a generic `GET /articles` feed + Markdown/HTML download so any stack (Webflow, Shopify, custom) can consume. Cheap to build, unblocks everything else.

**Recommended MVP order:** export/headless (day 1, unblocks our own use) → WordPress plugin (resale) → native Lovable feed.

---

## 7. Rank tracking (D3)
- Per keyword per site: store daily position, URL, and delta. Sources, cheapest-first:
  - **Google Search Console API** (free, truthful, but only *your own* verified sites — perfect for us and for any customer who connects GSC).
  - **SERP scraping API** (SerpAPI/DataForSEO) for keywords/competitors GSC won't show — metered cost, gate behind higher plans.
- Dashboard: keyword table (position, ∆7d/∆28d, striking-distance flag), organic-sessions trend (GA4), and the north-star we already defined — **demo bookings from organic** (`hms-seo-plan.md` §9). Reuse the visual language of our existing HTML dashboards.

---

## 8. Architecture & stack (reuse what we run)

```
Next.js dashboard (Vercel)                ← operator + customer UI
        │
Supabase (Postgres + Auth + RLS)          ← we already use this for BookATreatment
   ├─ tenants, sites, keywords, articles, rankings, brand_kits, image_library, jobs
   └─ Row-Level Security = the multi-tenant boundary (built in from day 1, D1)
        │
Job runner: Supabase cron → queue → worker (or Make.com for glue)
   ├─ Claude API (Sonnet draft / Opus research)   ← D4
   ├─ SERP API (SerpAPI or DataForSEO)
   └─ Search Console API + GA4 API
        │
Connectors: WordPress plugin · Lovable feed · headless /articles · export
Billing: Stripe (subscriptions) — only when we flip to resale
```

**Data model (first cut):**
`tenants` · `sites (tenant_id, platform, connector_creds)` · `brand_kits (voice, entity_rules, banned_claims, cta, internal_links)` · `image_library (tenant_id, approved assets only)` · `keywords (site_id, term, intent, priority)` · `articles (site_id, keyword_id, status, title, meta, body, url, published_at)` · `rankings (keyword_id, date, position, url)` · `jobs (site_id, type, state, run_at)`.

Multi-tenancy via RLS from the start (D1) is cheap now and saves a rewrite later, even though we run a single tenant (ourselves) first.

---

## 9. Backlink building — deliberately deferred (read this)
AutoSEO advertises "100+ DA of backlinks/month." Automated link building is the part most likely to be **low-quality PBN/link-farm** links that violate **Google's link-spam policy** and can get a site penalised. For a real business (ours) and for paying customers, shipping risky links is a liability, not a feature. **v1 does not auto-build links.** Instead we support the legitimate version from `hms-seo-plan.md §7`: directory/citation submissions, digital-PR/outreach *assistance* (draft pitches, find prospects), and internal-linking automation (which we get for free in the engine). Revisit only with a white-hat, disclosed approach.

## 10. Compliance guardrail — HIFU is a regulated space (don't skip)
HIFU machines/treatments touch **TGA therapeutic-goods advertising rules** in Australia (claims about medical/aesthetic outcomes, before/after imagery, prohibited representations). An AI writing daily articles about "HIFU results" can wander into non-compliant claims fast. The **Compliance Gate (§5 step 4)** must screen therapeutic claims and before/after usage — this is both self-protection and, again, a **sellable feature** for any regulated-industry customer (med-spa, dental, cosmetic). Bake it in; don't bolt it on.

---

## 11. Unit economics — can we actually undercut them?
Rough per-article cost with Claude (order-of-magnitude, verify before pricing):
- Research + draft + QA passes ≈ a few $ of tokens per article (Sonnet draft is cheap; Opus research pass is the main cost).
- SERP API ≈ cents–low-dollars per keyword/day depending on provider/plan.
- Fixed: Supabase + Vercel + domain ≈ tens of $/mo total at low volume.

**Implication:** one daily article ≈ single-digit-dollars/site/month of variable cost. AutoSEO charges **$79–199/mo**. That's a **fat enough margin** to (a) run our own sites at near-zero and (b) resell at, say, $39–99/mo and still win on price — *if* quality holds. **The moat isn't price, it's the brand-safety + compliance + approved-image guardrails** that a generic tool doesn't have. (Numbers here are estimates — §13 makes "validate real cost-per-article" the first build task.)

---

## 12. Build phases

**Phase 0 — Spike (validate the core loop, ~days).** One script: keyword → SERP research → Claude draft → Markdown out, run for a real HMS keyword ("how much does a HIFU machine cost in Australia"). Confirm quality + real token cost. Go/no-go on §11.

**Phase 1 — Engine for us (MVP).** Supabase schema + RLS; the daily pipeline (§5); brand kit + approved-image library + compliance gate; **review-mode approval queue**; **export/headless output**. Run HMS on it in review mode. _Success = we publish 5 on-brand articles we'd have paid AutoSEO for._

**Phase 2 — Publish + track.** WordPress plugin; Lovable feed for HMS; GSC rank tracking + dashboard; flip HMS to `auto`. Cancel the AutoSEO subscription. _Success = AutoSEO sub cancelled, rankings tracked._

**Phase 3 — Productise (only if Phases 1–2 prove out).** Tenant signup, Stripe billing, self-serve site-connect, customer dashboard, onboarding. First external customer = a Brisbane HIFU/BAT clinic we already know. _Success = 1 paying customer._

---

## 13. Immediate next steps
1. **You:** sign off / flip the four decisions in §1.
2. **Me:** build the **Phase 0 spike** and report back real article quality + real cost-per-article (this de-risks the whole thing and the resale margin in §11).
3. **Me:** if the spike looks good, stand up the Supabase schema (§8) and Phase 1 pipeline.

## 14. Open questions
- **Q1 (Hostinger):** keep Brisbane HIFU's blog on Hostinger (export/paste only) or migrate its blog to a headless feed? Affects whether Brisbane HIFU is "auto" or "assisted."
- **Q2 (volume):** daily (AutoSEO's promise) or 2–3×/week? `hms-seo-plan.md` says ~2/month "to start" — daily may be more than a niche B2B site needs; quality > cadence for commercial-intent buyers.
- **Q3 (resale name/brand):** does this sit under **teamneo.tech** / a new brand? Sold alongside BookATreatment to the same clinics, or separate?
- **Q4 (keyword data source):** rely on free GSC + Google Ads Search Terms (our current edge), or pay for a keyword-volume API to make it credible for resale customers who don't have our ad history?
```
