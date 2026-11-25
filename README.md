# AirLeo

AirLeo is a lightweight, responsive, single-page home for daily motivation, thoughtful quotes, mini challenges, and community links by **Leo the Programmer**.

## What works today

- Responsive landing page with mobile navigation and keyboard-visible focus states.
- Daily quote card with original AirLeo reminders and optional attributed quotes loaded from PositiveQuotation.
- Quote mood matching and automatic rotation, with a local fallback when the quote service is unavailable.
- Save, remove, share, and copy/export saved quotes. Saved items stay in the current browser and do not sync between devices.
- Private daily mood check-in stored locally in the browser.
- Rotating mini challenges.
- Quote requests and community submissions prepared as WhatsApp drafts. Visitors review and send messages themselves; submissions are not stored or published automatically.
- Cream and dark themes, reduced-motion support, social sharing metadata, and safe external-link handling.

## Run locally

This is a static site; no build step or package installation is required.

1. Clone the repository.
2. Open `index.html` directly in a browser, or serve the repository root with any static HTTP server.
3. Run the structural and JavaScript checks:

```bash
python scripts/validate_site.py
```

The validator checks the document language, unique IDs, required interface elements, label targets, the single main landmark, and inline JavaScript syntax (using Node.js).

## Deployment

GitHub Pages can publish the root of the `main` branch from **Settings → Pages**. Changes on the development branch are not live until they are merged and the publishing source is configured.

## Important boundaries

- No account system, server-side storage, or cross-device sync is currently implemented.
- Saved quotes, theme preference, and mood check-in use browser-local storage.
- WhatsApp forms only prepare a message; they do not send it automatically.
- Do not add payment secrets or private API keys to this static client-side project. Any future payment or authenticated data feature needs a trusted server-side implementation and appropriate access rules.

## Community accounts and privacy-conscious analytics

The optional member area and anonymous visit counter use the existing Supabase project selected for AirLeo. The new tables are prefixed `airleo_`; existing tables and application data in this shared Supabase project are not modified.

### Configure Supabase Auth

1. In the Supabase dashboard, open **Authentication → URL Configuration**.
2. Set the Site URL to the published AirLeo GitHub Pages URL (for a project site, this is usually `https://<owner>.github.io/<repository>/`).
3. Add that same URL to the allowed redirect URLs.
4. Enable email/password sign-in. If email confirmation is enabled, members must confirm their email before logging in.

The browser uses only the project's publishable key. Never put a service-role or secret key in this repository.

### Give the site owner admin access

After the owner has created an account and confirmed the email address, run this SQL in the Supabase SQL Editor, replacing the email with the owner's exact sign-in email:

```sql
update public.airleo_profiles
set is_admin = true
where user_id = (
  select id from auth.users
  where lower(email) = lower('OWNER_EMAIL_HERE')
);
```

Only this explicit admin profile can view anonymous visit totals and review member submissions. The website does not assume that the first registrant is the administrator. Keep this SQL and the Supabase dashboard restricted to trusted administrators.

### What is collected

- Anonymous analytics are opt-in. A small consent prompt lets visitors allow or decline.
- If allowed, AirLeo records a page-view event, a random per-tab session identifier, the page path, and timestamp. It does not collect IP addresses, precise location, names, emails, or full user-agent strings for analytics.
- Account registration stores the member's email with Supabase Auth and a display name in the AirLeo profile table.
- Community posts are private to their author and the site administrator while pending or rejected. Approved posts appear on the public community board. Admins can mark them pending, approved, or rejected.
- Visitors can continue using the original quotes, mood check-ins, saved quotes, challenges, and WhatsApp forms without an account.

The project is static GitHub Pages hosting, so all authorization is enforced by Supabase Row Level Security, not by hiding interface elements. The analytics table is insert-only for visitors; members can read only their own profile and submissions. Admin access is granted manually through the SQL above.
