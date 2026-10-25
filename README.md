# AirLeo

AirLeo is a lightweight, mobile-friendly home for daily motivation, quotes, mini challenges, and community links by LEO THE PROGRAMMER.

## Current starter

- `index.html` is a static, responsive landing page.
- Daily quotes and the “Give It A Go” challenge work in the browser without a database.
- WhatsApp community and contact links are included.
- The page avoids collecting visitor IP data.

## Next steps

1. Configure GitHub Pages in **Settings → Pages** and publish from the `main` branch, root folder. GitHub Pages needs an entry file such as `index.html` in the publishing folder.
2. Configure Firebase Authentication and Firestore before adding accounts or saved user content. Keep Firestore rules closed until the data model and access rules are ready.
3. Add payment processing only with a secure server-side payment verification flow; never put a Paystack secret key in browser code.

This is a starter version. Sign-in, saved quotes, custom quote requests, and payment verification are not implemented yet.
