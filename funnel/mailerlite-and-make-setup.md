# MailerLite + Make — Copy-Paste Setup
Everything below is ready to paste. Order: MailerLite first (so the field keys exist), then Make.

---

## PART A — MailerLite setup

### A1. Create the group
**Subscribers → Groups → Create group:**
```
HIFU Machine Leads
```
This group is the trigger for your `HMS-Email-Sequence` automation (set the automation trigger to: *"When a subscriber joins a group → HIFU Machine Leads"*).

### A2. Create these custom fields
**Subscribers → Fields → Create field** (type = Text for all). MailerLite auto-creates the **key** from the name — confirm it matches:

| Field name | Type | Key |
|---|---|---|
| Suburb | Text | `suburb` |
| Package | Text | `package` |
| Buy preference | Text | `buy_preference` |
| Lead message | Text | `lead_message` |
| Source | Text | `source` |

*(Name, Email and Phone already exist as standard fields — don't recreate them.)*

### A3. Get your API key
**Integrations → Developer API → Generate new token** → copy it. You'll paste this into Make (Part B, Module 2).

---

## PART B — Alert email (copy-paste into Make's Email module)

**To:**
```
jk@startupbusiness4sale.com
```

**Subject:**
```
🔥 New HIFU lead: {{1.name}} — {{1.package}} ({{1.buy_preference}})
```

**Body:**
```
New HIFU machine enquiry 🎉

Name:              {{1.name}}
Email:             {{1.email}}
Phone:             {{1.phone}}
Suburb:            {{1.suburb}}
Package interest:  {{1.package}}
Buying preference: {{1.buy_preference}}
Message:           {{1.message}}

Source:            {{1.source}}

⏱ Reply within the hour. Book them a demo:
https://app.bookatreatment.ai/book/mpt-demo-1hr
```
> The `{{1.x}}` tokens map to the **Webhook (Module 1)** output. In Make, type the labels and insert each value from the field-picker rather than typing the token by hand.

---

## PART C — Make scenario, step by step

**Create scenario:** Make → **Create a new scenario** → name it `HIFU Lead Capture`.

### Module 1 — Webhooks → Custom webhook  (trigger)
1. Add module → **Webhooks → Custom webhook** → **Add** → name `HIFU lead form` → **Save**.
2. **Copy the webhook URL** (this goes into the Lovable form, STEP 3).
3. Click **Run once**, then submit a test from the form (or any POST) so Make learns these fields:
   `name, email, phone, suburb, package, buy_preference, message, source`

### Module 2 — MailerLite → Create/Update a Subscriber
1. Add **MailerLite → Create/Update a Subscriber** after the webhook.
2. **Connection → Add** → paste the **API key** from A3.
3. Map:
   - **Email** → `{{1.email}}`
   - **Name** → `{{1.name}}`
   - **Fields:** `phone` → `{{1.phone}}`, `suburb` → `{{1.suburb}}`, `package` → `{{1.package}}`, `buy_preference` → `{{1.buy_preference}}`, `lead_message` → `{{1.message}}`, `source` → `{{1.source}}`
   - **Groups:** add **HIFU Machine Leads** ✅ (this fires the email sequence)

### Module 3 — Email → Send an email  (alert)
1. Add **Email → Send an email** (or **Gmail → Send an email** if you prefer Gmail).
2. Paste **To / Subject / Body** from Part B above.

### Module 4 — Webhooks → Webhook response  (thank-you)
1. Add **Webhooks → Webhook response**.
2. **Status:** `200`
3. **Body:**
```json
{ "status": "ok", "booking": "https://app.bookatreatment.ai/book/mpt-demo-1hr" }
```

### Finish
- Bottom-left: **scheduling → Immediately**; toggle scenario **ON**.
- Paste the **webhook URL** into the Lovable form (STEP 3). Demo button → `https://app.bookatreatment.ai/book/mpt-demo-1hr`.

### Test
1. Submit a real test from the live form.
2. ✅ Lead in MailerLite (HIFU Machine Leads group) → Email 1 sends.
3. ✅ Alert email arrives at `jk@startupbusiness4sale.com`.
4. ✅ Form shows the **Book a Demo** button.

---

### What Make needs from you (the only inputs)
1. **MailerLite API key** (A3).
2. **Confirm the alert inbox** — `jk@startupbusiness4sale.com` monitored? If not, give a Gmail you check.
3. Everything else (field mappings, alert copy, booking link, response) is specified above.
