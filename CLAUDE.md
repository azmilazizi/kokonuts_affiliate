# Kokonuts Affiliate

Public front end at https://affiliate.kokonuts.my: a numbered directory of
affiliate products (Shopee + TikTok Shop). Viewers come from videos ("cari nombor 23").

## Stack
- Flutter web (3.35+, Dart 3.9). Packages: `http`, `url_launcher` only. Add nothing without a strong reason.
- No state-management library: `StatefulWidget` / `ValueNotifier`.
- Hosted on cPanel (Apache). The compiled `build/web` is committed and deployed by `.cpanel.yml`.

## Structure
```
lib/config.dart        apiBase (API_BASE), useMock (USE_MOCK), header details, kOrange
lib/models.dart        Item, Category, Catalog (+ forgiving fromJson)
lib/api.dart           loadCatalog(): mock json or GET {API_BASE}/affiliate/public/items
lib/search.dart        filterItems() / exactNumber(): pure, unit tested
lib/home_page.dart     the one screen: header, tabs, grid, states, footer
lib/widgets/           store_header, product_card, buy_sheet, net_image
assets/mock.json       sample data for USE_MOCK=true
web/index.html         title/meta/favicon + CSS splash
web/flutter_bootstrap.js  custom: no service worker, hides the splash on first frame
web/.htaccess          /N short link → CRM, force https, fallback to index.html, no-cache
deploy.sh              release build
```

## API contract
`GET {API_BASE}/affiliate/public/items`
```json
{ "items": [ { "item_no": 145, "name": "Cordless Vacuum Murah", "image_url": "https://...",
    "price": 30.31, "category_id": 3,
    "links": { "shopee": "https://s.shopee.com.my/...", "tiktok": null } } ],
  "categories": [ { "id": 3, "name": "Rumah" } ] }
```
`price`, `category_id` and each link may be null. The CRM must send CORS headers for this origin.
Short links: `affiliate.kokonuts.my/23` → 302 → `https://crm.kokonuts.my/affiliate/go/23`.

## Rules
- Minimal: one screen. No detail pages, no login, no analytics or tracking scripts.
- Never show discount %, sold count or "original price". Show price only if it isn't null.
- **Item numbers are permanent.** Never renumber or reuse them; old videos point to them.
- Grid is always sorted by item_no descending. A digits-only search puts the exact number first and highlights it.
- Links open in the same tab (`webOnlyWindowName: '_self'`) for in-app browsers.
- Network images use `WebHtmlElementStrategy.fallback` (no CORS on Shopee CDN).
- UI text is Bahasa Melayu (casual). Keep the code plain and commented where it's non-obvious.
- After changing the app: `flutter analyze`, `flutter test`, `./deploy.sh`, then commit `build/web`.
