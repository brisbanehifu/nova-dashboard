# Make.com — Lead-Capture Spine (build recipe)
The automation that turns a Lovable form submission into a nurtured lead.
**Flow:** Lovable form → **Webhook** → **MailerLite** (subscribe + trigger `HMS-Email-Sequence`) → **Email alert** to Kim → **Webhook response** (thank-you + BookATreatment demo link).

> ⚠️ Built as a recipe because the Make API needs an approval the remote session can't grant. Either follow these steps in the Make UI (~15 min), or approve the Make connector and I'll build it via API.

---

## Module 1 — Webhook (trigger)
1. Make → **Create a new scenario** → add **Webhooks → Custom webhook**.
2. **Add** a webhook, name it `HIFU lead form`. Copy the generated URL — this is the URL that goes in the Lovable form (STEP 3 of `lovable-hifu-machines-landing.md`).
3. The form must POST JSON in this shape (the **payload contract**):
```json
{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "phone": "0400 000 000",
  "suburb": "Southport QLD",
  "package": "15D",            // 13D | 15D | Clinic Starter Kit | Not sure
  "buy_preference": "Finance", // Outright | Finance | Discuss
  "message": "Keen to start in spring",
  "source": "hifu-machines-landing"
}
```
4. Run the scenario once ("Determine data structure"), submit a test from the form (or Postman), so Make learns the fields.

## Module 2 — MailerLite (subscribe + start the sequence)
1. Add **MailerLite → Create/Update a Subscriber** (connect your MailerLite account — generate an API key in MailerLite → Integrations → Developer API).
2. Map: **Email** = `email`; **Name** = `name`; **Fields** → phone = `phone`, plus custom fields for `suburb`, `package`, `buy_preference` (create these custom fields in MailerLite first).
3. **Group:** add the subscriber to the group that triggers your **`HMS-Email-Sequence`** automation (in MailerLite, the automation's trigger should be "when subscriber joins group `HIFU Machine Leads`"). Adding them here = the 3 emails fire automatically.

## Module 3 — Email alert to Kim
1. Add **Email → Send an email** (or Gmail → Send) so a human knows instantly.
2. **To:** `jk@startupbusiness4sale.com` *(confirm this is monitored — or switch to a Gmail you live in).*
3. **Subject:** `🔥 New HIFU lead: {{name}} — {{package}} ({{buy_preference}})`
4. **Body:** all fields — name, email, phone, suburb, package, buy_preference, message.

## Module 4 — Webhook response (thank-you + booking)
1. Add **Webhooks → Webhook response**.
2. **Status:** 200. **Body:** return the BookATreatment demo link so the form shows the booking step:
```json
{ "status": "ok", "booking": "https://app.bookatreatment.ai/book/mpt-demo-1hr" }
```
3. In Lovable, on success show: "Thanks {{first name}} — book your demo:" + a **Book a Demo** button → `https://app.bookatreatment.ai/book/mpt-demo-1hr`.

---

## Connections you'll need
- **MailerLite** API key (free plan is fine).
- **Email/Gmail** connection for the alert.
- **BookATreatment** demo booking — already set up: `https://app.bookatreatment.ai/book/mpt-demo-1hr` (1-hr MPT demo). Paste into Module 4 and the Lovable form. No Calendly needed.

## Test checklist
1. Submit a real test from the Lovable form.
2. Confirm: lead appears in MailerLite (right group) → Email 1 arrives → alert hits `jk@startupbusiness4sale.com` → form shows the Book a Demo step.
3. Turn the scenario **ON** and set scheduling to **Immediately** (run on each webhook).

## Optional add-ons (later)
- Add a **Notion/Google Sheet** module to log every lead as a CRM backup.
- Add a **Router** to tag finance vs outright leads differently.
- Add **Meta Conversions API** so Facebook/Zeely learns who converts.
