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
