#!/usr/bin/env bash
# Bundle Node.js + scrapers + node_modules into the macOS app.
#
# Usage:
#   scripts/prepare_macos.sh [debug|release]
#
# Copies into the built .app bundle's Contents/Resources/:
#   node                 – Node.js binary
#   scrapers/*.js        – scraper scripts + cdp-helper.js
#   scrapers/node_modules/  – runtime dependencies (puppeteer-core)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRAPERS_DIR="$PROJECT_ROOT/assets/scrapers"
BUILD_MODE="${1:-debug}"

BUILD_DIR="$(echo "${BUILD_MODE:0:1}" | tr '[:lower:]' '[:upper:]')${BUILD_MODE:1}"
APP_PATH="$PROJECT_ROOT/build/macos/Build/Products/$BUILD_DIR/persona_flutter.app"
RESOURCES="$APP_PATH/Contents/Resources"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: app bundle not found at $APP_PATH" >&2
  echo "       Run 'flutter build macos --$BUILD_MODE' first." >&2
  exit 1
fi

# --- Locate node ---
NODE_PATH="$(command -v node 2>/dev/null || true)"
if [[ -z "$NODE_PATH" ]]; then
  NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  for d in "$NVM_DIR"/versions/node/*/bin/node; do
    [[ -x "$d" ]] && NODE_PATH="$d"
  done
fi
if [[ -z "$NODE_PATH" || ! -x "$NODE_PATH" ]]; then
  echo "error: Node.js not found" >&2
  exit 1
fi

echo "==> Node: $NODE_PATH ($("$NODE_PATH" --version))"

# --- Copy resources ---
mkdir -p "$RESOURCES/scrapers/node_modules"

cp "$NODE_PATH" "$RESOURCES/node"
chmod +x "$RESOURCES/node"

for f in "$SCRAPERS_DIR"/*.js; do
  cp "$f" "$RESOURCES/scrapers/"
done

cp -R "$SCRAPERS_DIR/node_modules/"* "$RESOURCES/scrapers/node_modules/"

echo "==> Bundled into $RESOURCES"
echo "    node:               $(du -h "$RESOURCES/node" | cut -f1)"
echo "    scrapers/:          $(ls "$RESOURCES/scrapers/"*.js | wc -l | tr -d ' ') scripts"
echo "    node_modules/:      $(du -sh "$RESOURCES/scrapers/node_modules" | cut -f1)"
