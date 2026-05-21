# Doom build

What gets built: Emscripten doomgeneric → JS+WASM, hosted in an iframe at
`/doom/index.html`. License boundary is the iframe — GPLv2 doomgeneric stays
out of the Drawdy bundle.

## One command

```sh
pnpm build:doom
```

That script (`scripts/build-doom.sh`):

1. Clones `ozkl/doomgeneric` into `vendor/doomgeneric/` if missing.
2. Copies our `Makefile.web` override into the vendor tree.
3. Fetches Freedoom Phase 1 (BSD-licensed) as the WAD.
4. Runs `make -f Makefile.web` (emcc).
5. Stages `.js` / `.wasm` / `.data` into `frontend/public/doom/`.

`vendor/` and the build outputs are gitignored — re-run the script after a
fresh clone.

## Why our Makefile.web (instead of upstream's Makefile.emscripten)

- Upstream uses host `sdl2-config`. Doesn't work with emcc — needs
  `-sUSE_SDL=2 -sUSE_SDL_MIXER=2` for Emscripten's SDL2 port.
- Upstream emits a self-running `.html`. We use `MODULARIZE=1
  EXPORT_NAME=createDoomModule` so our iframe page controls startup
  (click-to-start for the audio-gesture requirement).

No upstream source files are modified.
