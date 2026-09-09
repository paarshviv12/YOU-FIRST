# Wiring up responses — about 10 minutes

Four files:

| File | Where it goes |
|---|---|
| `supabase-setup.sql` | pasted into Supabase once, then never again |
| `index.html` | your public page — the one on Vercel |
| `dashboard.html` | **stays on your Mac.** Never deploy this |
| `SETUP.md` | this file |

---

## 1. Make the table

1. Go to **supabase.com** → sign in → **New project**. Any name; pick the region closest to you (Mumbai if it's offered). Save the database password somewhere — you won't need it today, but you can't see it again.
2. Wait for the project to finish provisioning (~2 min).
3. Left sidebar → **SQL Editor** → **New query**.
4. Paste the whole of `supabase-setup.sql` → **Run**.

You should see a single result: `rls_is_on = true`. That's the whole schema plus its access rules.

---

## 2. Get your two sets of keys

**Project Settings** (gear icon) → **API**. You need three values:

| Value | Goes into | Can it be public? |
|---|---|---|
| **Project URL** | both files | yes |
| **anon public** key | `index.html` | **yes** — insert-only |
| **service_role** key | `dashboard.html` | **never** |

### Why two keys

The table has exactly one access rule: the `anon` key may **insert** a row and do nothing else. It cannot read, edit or delete. That's what makes it safe to ship inside a public web page — someone can view-source, take the key, and still not be able to pull out a single response.

The `service_role` key ignores that rule entirely. It's how the dashboard reads everything. If it ever reaches a public file, anyone who finds it owns your whole database.

**So: never commit `dashboard.html`, never upload it, never paste the service_role key into `index.html`.**

---

## 3. Point the form at it

Open `index.html`, find the `CONFIG` block near the top of the `<script>` (around line 1490), fill in two lines:

```js
var SUPABASE_URL      = "https://xxxxxxxx.supabase.co";
var SUPABASE_ANON_KEY = "eyJhbG...";      // the anon public key
var WA_NUMBER         = "";               // optional
```

Push it, let Vercel redeploy, then **fill the form in yourself once**. Check Supabase → **Table Editor** → `responses`. Your row should be there.

If it isn't, open the browser console on the live page — a failed save logs `You First — save failed:` with the reason. The two usual causes are a stray space in the key, or the SQL not having been run.

---

## 4. Point the dashboard at it

Open `dashboard.html`, same idea, near the top:

```js
var SUPABASE_URL = "https://xxxxxxxx.supabase.co";
var SERVICE_KEY  = "eyJhbG...";           // the service_role key
```

Save, then double-click the file. It opens in your browser and starts polling every 10 seconds.

**If it says it can't reach Supabase**, your browser is blocking the request because the page was opened from disk. Fix it in one line:

```bash
cd ~/Desktop/YOU-FIRST
python3 -m http.server 8000
```

Then open `http://localhost:8000/dashboard.html`. Stop the server with Ctrl-C when you're done.

---

## What the dashboard shows

- **Responses** — total collected
- **Most chosen rating** — the mode of Q2, with ties shown as `7 & 8`
- **Would let it buy** — the Yes/No split from Q3, as a share and a count
- **Average rating** — mean, with the median underneath, since a skewed set makes those diverge
- **What keeps coming up** — Q1 answers sorted into recurring complaints (size and fit, filters, delivery, returns, and so on). One answer can land in several. Click a row to read only those answers, with the matching words highlighted
- **Their own words** — repeated phrases mined straight from the text, for anything the buckets miss
- **Every response** — the full list, filterable by Yes/No, with a CSV export

Two deliberate choices worth knowing:

**Ratings can be null.** The slider starts unset, so someone who never touched it is recorded as `null`, not as 5. Those people are excluded from the mode and the average rather than dragging them to the middle. "4 of 10 who rated" tells you how many actually answered.

**Themes count people, not mentions.** Someone who says "size" four times counts once. You want how many people raised a point, not how emphatically one person did.

---

## If you need to reset

To wipe test responses before going live, in the SQL Editor:

```sql
delete from public.responses;
```

To see everything as a table without the dashboard: **Table Editor** → `responses`.

---

## Limits

Supabase's free tier gives you 500 MB of database and pauses a project after 7 days with no activity (one visit wakes it). For a survey this is effectively unlimited — a response is about 300 bytes, so 500 MB is over a million of them.

There's no rate limiting on the insert. If someone decides to spam the form, the table will take it. For a competition survey that's a fair trade; if it becomes a problem, add a Cloudflare Turnstile check or a per-IP limit in a Supabase Edge Function.
