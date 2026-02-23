# TODO

- [x] Check if printing SVG files with a visible "offset" layer in Inkscape causes problems with printing. 
  **Findings:** `scripts/inkscape-render.pl` uses `inkscape --export-id-only`. If the "offset" layer is visible and is a child of (or the same as) the exported ID, it **will** be printed. 
  **Status:** The `card/ffzg-2026-v2-manual-align-backup.svg` currently lacks the `print-front` and `print-back` IDs required by the render script.
- [ ] Restore/Add `print-front` and `print-back` IDs to the 2026 template.
- [ ] Ensure the "offset" layer remains `display:none` in the master template to prevent accidental printing, while using `scripts/render-preview.sh` for visual checks.
