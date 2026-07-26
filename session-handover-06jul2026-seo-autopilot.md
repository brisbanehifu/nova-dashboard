# Session Handover — SEO Autopilot (build our own AutoSEO, then resell)
**Date:** 2026-07-06 · **Repo:** nova-dashboard · **Branch:** `claude/product-tool-spec-s2ua6n`
**⚠️ Run the next session in DESKTOP/local Claude Code** — the next real step (the Phase 0 spike) needs a live Claude API key, a SERP API key, running code, and Kim's local brand images. Those are blocked or awkward in the remote web session. Read `CONTEXT.md` + `CLAUDE.md` + `seo-autopilot/product-spec.md` first.

---

## Where we got to (this session)
- Figured out the tool Jez wants to stop paying for = **AutoSEO** (getautoseo.com, ~US$79–199/mo): AI writes 1 SEO article/day, auto-publishes to the blog, tracks rankings, "builds backlinks."
- Wrote a full product spec to build our own version → **`seo-autopilot/product-spec.md`**.
- Committed + pushed to `claude/product-tool-spec-s2ua6n`, opened **draft PR #11** (`brisbanehifu/nova-dashboard`). No CI on this repo; nothing else outstanding on the PR.
- **Not started:** any code. This is still plan-only. Next step is the spike.

## ▶︎ Prompt for the next (local) session — copy-paste
```
Read CONTEXT.md, CLAUDE.md, and seo-autopilot/product-spec.md first. You are continuing the
"SEO Autopilot" build for Kim/Jez — our own version of AutoSEO (getautoseo.com) to run our
sites for API-cost and later resell like BookATreatment.

GOAL THIS SESSION: build the PHASE 0 SPIKE from spec §12 and report REAL numbers, so we can
go/no-go on quality + resale margin before building anything bigger.

Build one small script (Node or Python) that does, for a single keyword, end to end:
  1. TOPIC: take a target keyword, e.g. "how much does a HIFU machine cost in Australia"
     (from funnel/hms-seo-plan.md §1).
  2. SERP RESEARCH: fetch the top ~10 Google results (use a SERP API key — SerpAPI or
     DataForSEO) and extract headings + People-Also-Ask + coverage gaps into a brief.
  3. DRAFT: call the Claude API — Opus for the research/outline pass, Sonnet for the
     1,000–1,500 word draft. System prompt = HMS brand kit (voice + hard rules below +
     prices from funnel/deals.md + a demo CTA + internal-link targets from
     funnel/hms-seo-plan.md §2). Output: H1 w/ keyword, H2/H3, title <=60 chars,
     meta <=155 chars, and Markdown body.
  4. IMAGE RULE: do NOT generate any image. Only reference approved files from
     funnel/brand-assets-manifest.md, or leave a marked placeholder. (Golden Rule.)
  5. OUTPUT: write the article to seo-autopilot/spike-output/<keyword-slug>.md.

THEN REPORT BACK (this is the actual deliverable of the spike):
  - real token cost of one article (Opus pass + Sonnet pass, in $),
  - SERP API cost per keyword,
  - a quality read: is this an article we'd have paid AutoSEO for? What's weak?
  - recommendation: proceed to Phase 1, or adjust the approach?

Keep API keys in a local .env — DO NOT commit them. Add seo-autopilot/.env to .gitignore.
Commit the script + the sample output (not the keys). Update PR #11 or open a follow-up.

HARD RULES (CONTEXT.md): 🔒 GOLDEN RULE — never recreate/redraw/restyle/"improve" or
AI-generate the machines or clinic photos; only embed Kim's actual approved files, zero drift
(missing photo = placeholder + ASK). Marketing shows "HIFU Machine Sales" only (never
Neo-Klien). HIFU is TGA-regulated — screen therapeutic/results claims (spec §10).
Prices from funnel/deals.md: 13D $19,995 · 15D $29,995 · Clinic Starter Kit $49,995 (ex GST).
```

## The 4 decisions still needing Jez/Kim sign-off (spec §1)
The spec assumed a recommended default for each so it's buildable, but confirm/flip these — they change scope:
1. **D1 Scope** — default: our sites first, architected multi-tenant-ready (vs full SaaS now / vs bare-minimum replacement).
2. **D2 Publishing** — default: our sites + a WordPress plugin (vs add Webflow/Shopify/headless / vs export-only).
3. **D3 Features** — default: article engine + auto-publish + rank tracking; **backlinks deferred** (spec §9 explains why — penalty risk).
4. **D4 AI engine** — default: Claude API (Sonnet draft / Opus research).

I couldn't ask these interactively in the web session (prompt was blocked); that's easier locally.

## Why local / desktop is better for this
Things the remote web session couldn't do that a local session can:
- **Run the spike** with real Claude + SERP API keys (env-based) and print real cost/quality — the whole point of Phase 0.
- **Supabase CLI** for local schema/migrations dev (spec §8) once we pass the spike. (BookATreatment already uses Supabase — reuse patterns/keys.)
- **Read Kim's local brand images** at `C:\Users\kimkl\Documents\Claude\HMS-Email-Sequence\images\` to seed the tenant "Approved Image Library" (spec §3). Copy into `funnel/images/` as before.
- **Make.com** glue if we use it for scheduling — its API is blocked from remote web sessions (CONTEXT.md rule #5), fine locally/desktop.
- Interactive question prompts + `send_later` scheduling both need approval the non-interactive web session can't grant.

## Key files
- `seo-autopilot/product-spec.md` — **the plan** (engine pipeline, connectors, data model, unit economics, phases, open questions). Read this first.
- `funnel/hms-seo-plan.md` — target keywords, page architecture, content ideas (feeds spike topic selection).
- `funnel/deals.md` — price source of truth (must match in any article).
- `funnel/brand-assets-manifest.md` — the approved image list + the Golden Rule.
- `seo-fastest-wins-brisbanehifu.html` — our existing live SEO audit + the GSC / Google Ads Search Terms method the engine reuses for topic selection.

## Open questions carried forward (spec §14)
- **Hostinger:** Brisbane HIFU's blog is on Hostinger Website Builder (no clean API) — export/paste vs migrate its blog to a headless feed?
- **Cadence:** daily (AutoSEO's promise) vs 2–3×/week? hms-seo-plan says ~2/month to start — for a niche B2B buyer, quality may beat cadence.
- **Resale brand:** does this live under teamneo.tech / sit alongside BookATreatment to the same clinics, or a separate brand?
- **Keyword data:** rely on free GSC + Google Ads Search Terms (our edge) or pay for a keyword-volume API to be credible for resale customers who lack our ad history?

## PR / branch state
- Branch `claude/product-tool-spec-s2ua6n` is pushed; **draft PR #11** open against `main`. If you keep working on the same branch locally, just commit + push and the PR updates. If PR #11 gets merged first, start follow-up work from a fresh branch off `main` (don't stack on merged history).
```
