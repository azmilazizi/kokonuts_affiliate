#!/bin/sh
# Build the live site into build/web, ready to commit + push.
# Usage: ./deploy.sh            (then: git add -A && git commit -m "..." && git push)
set -e
flutter build web --release --dart-define=API_BASE=https://crm.kokonuts.my
# Safety check: the .htaccess must be in the output.
test -f build/web/.htaccess || { echo "ERROR: build/web/.htaccess missing"; exit 1; }
echo "Built OK. Now commit + push, then in cPanel: Git Version Control -> Manage -> Pull or Deploy -> Update from Remote -> Deploy HEAD Commit."
