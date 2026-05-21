#!/usr/bin/env bash
# Builds doomgeneric to WebAssembly and stages the artifacts at
# frontend/public/doom/. Uses Freedoom Phase 1 (BSD-licensed) as the WAD,
# so nothing in the build chain has copyright distribution issues.
#
# Idempotent — re-running is cheap once the vendor checkout, WAD, and
# Emscripten cache are warm. Pulls doomgeneric upstream on first run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts/doom"
VENDOR_ROOT="$REPO_ROOT/vendor/doomgeneric"
DG_DIR="$VENDOR_ROOT/doomgeneric"
OUT_DIR="$REPO_ROOT/frontend/public/doom"
WAD_PATH="$DG_DIR/doom1.wad"

DOOMGENERIC_REPO="https://github.com/ozkl/doomgeneric.git"
FREEDOOM_URL="https://github.com/freedoom/freedoom/releases/download/v0.13.0/freedoom-0.13.0.zip"
FREEDOOM_ZIP="/tmp/freedoom-0.13.0.zip"

if ! command -v emcc >/dev/null 2>&1; then
    echo "error: emcc not on PATH. Install Emscripten and try again." >&2
    exit 1
fi

if [ ! -d "$VENDOR_ROOT" ]; then
    echo "→ Cloning doomgeneric ($DOOMGENERIC_REPO)…"
    mkdir -p "$(dirname "$VENDOR_ROOT")"
    git clone --depth 1 "$DOOMGENERIC_REPO" "$VENDOR_ROOT"
fi

echo "→ Installing build override (Makefile.web)…"
cp "$SCRIPTS_DIR/Makefile.web" "$DG_DIR/Makefile.web"

if [ ! -f "$WAD_PATH" ]; then
    echo "→ Fetching Freedoom Phase 1 WAD…"
    if [ ! -f "$FREEDOOM_ZIP" ]; then
        curl -L --fail "$FREEDOOM_URL" -o "$FREEDOOM_ZIP"
    fi
    unzip -p "$FREEDOOM_ZIP" freedoom-0.13.0/freedoom1.wad > "$WAD_PATH"
    echo "  → $WAD_PATH ($(wc -c < "$WAD_PATH" | awk '{print $1}') bytes)"
fi

echo "→ Building doomgeneric (emcc)…"
cd "$DG_DIR"
make -f Makefile.web

echo "→ Staging artifacts to $OUT_DIR/"
mkdir -p "$OUT_DIR"
cp doomgeneric.js doomgeneric.wasm doomgeneric.data "$OUT_DIR/"

echo "✓ Doom built. Run \`pnpm dev:frontend\` and drop the Doom widget onto a canvas."
