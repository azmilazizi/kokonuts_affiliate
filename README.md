# Kokonuts Affiliate

Public, numbered directory of affiliate products (Shopee + TikTok Shop) at
**https://affiliate.kokonuts.my**. It's a Flutter web app with one screen.

In videos: *"tekan link kat bio, cari nombor 23"* → `affiliate.kokonuts.my/?q=23`
or the short link `affiliate.kokonuts.my/23`.

## Local development

```sh
flutter pub get
flutter run -d chrome --dart-define=USE_MOCK=true     # uses assets/mock.json
flutter run -d chrome                                 # uses the real CRM API
flutter test                                          # search logic tests
```

Header name, avatar, cover and tagline live in `lib/config.dart`.
Replace `assets/avatar.png`, `assets/cover.png` and `web/favicon.png` with real images.

## Build

```sh
./deploy.sh
# same as: flutter build web --release --dart-define=API_BASE=https://crm.kokonuts.my
```

The output goes to `build/web/`, including `.htaccess`. `build/web` **is committed**
on purpose, because cPanel can't run Flutter.

## Deploy to cPanel

### One-time setup

1. **Domains** → Create A New Domain → `affiliate.kokonuts.my`.
   Untick "Share document root" and set the document root to `public_html/affiliate`.
2. **SSL/TLS Status** → tick the new domain → **Run AutoSSL**.
3. Choose one of the two options below.

### Option A: Git Version Control (recommended)

1. **Git Version Control** → Create → turn on *Clone a Repository*.
   - Clone URL: the GitHub repo URL (see "Private repo" below if it's private)
   - Repository Path: `repositories/kokonuts_affiliate` (**not** inside public_html)
2. Every update:
   1. Run `./deploy.sh` on your Mac, then `git add -A && git commit -m "update" && git push`.
   2. In cPanel: Git Version Control → Manage → **Pull or Deploy** → **Update from Remote** → **Deploy HEAD Commit**.
3. `.cpanel.yml` copies `build/web/` into `~/public_html/affiliate/`.
   If your document root is different, edit `DEPLOYPATH` in `.cpanel.yml`.

**Private repo:** cPanel must clone over SSH.
1. cPanel → **SSH Access** → Manage Keys → Generate a key (no passphrase), then Authorize it.
2. View the **public** key and add it on GitHub: repo → Settings → Deploy keys → Add (read-only).
3. Use the SSH clone URL: `git@github.com:<user>/kokonuts_affiliate.git`.

### Option B: Manual upload

1. Run `./deploy.sh`, then zip the **contents** of `build/web` (not the folder itself):
   `cd build/web && zip -r ../site.zip . && cd -`
2. **File Manager** → `public_html/affiliate` → Upload `site.zip` → right-click → **Extract**, then delete the zip.
3. **Settings** (top right) → tick **Show Hidden Files** → check that `.htaccess` is there.

## Troubleshooting

| Problem | Check |
|---|---|
| **Blank / white page** | Open DevTools → Console. A 404 on `main.dart.js` or `flutter_bootstrap.js` means you uploaded the `web` *folder* instead of its contents. Hard-refresh (Cmd+Shift+R). Make sure `<base href="/">` is in index.html (the default build does this). |
| **Images not showing** | Open the `image_url` directly in a browser. If it opens there, it's fine; the app already uses the `<img>` fallback for hosts without CORS. If it doesn't open, the URL is wrong or expired. Shopee CDN URLs sometimes change. |
| **"Tak dapat load barang"** | 1) Open `https://crm.kokonuts.my/affiliate/public/items` in a browser: does it return JSON? 2) Console says *CORS*: the CRM must send `Access-Control-Allow-Origin: https://affiliate.kokonuts.my` (or `*`) on that endpoint. 3) Was the build made with `USE_MOCK=true` by accident? Rebuild with `./deploy.sh`. |
| **Old version still showing** | `.htaccess` sets no-cache on index.html, main.dart.js and flutter_bootstrap.js. Check that `.htaccess` was uploaded (Show Hidden Files). Inside the TikTok/IG in-app browser, close it and reopen. |
| **Short link `/23` not redirecting** | `.htaccess` is missing, or mod_rewrite is off. Test `curl -I https://affiliate.kokonuts.my/23`: it should return `302` with `Location: https://crm.kokonuts.my/affiliate/go/23`. The CRM must implement `/affiliate/go/{n}`. |
| **http doesn't go to https** | Run AutoSSL again and wait for the certificate. If the site is behind Cloudflare, use SSL mode "Full". |
