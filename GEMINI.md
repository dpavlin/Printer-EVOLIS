# Printer Evolis - Project Memory

## Card Templates
- The primary single-sided template is `card/ffzg-2026-v3-single-side.svg`.
- Branch `ffzg-2026-v3` contains the latest stable templates and scripts.

## Printing Scripts Technical Insights
- **SVG Placeholder Mapping:** When using Croatian or non-ASCII characters in SVG templates (like `Knjižničarko`, `Čitalić`), Perl scripts (e.g., `inkscape-render.pl`) must:
    - Use `use utf8;`
    - Decode command-line arguments using `Encode::decode_utf8`.
    - Open file handles with `:utf8`.
    - Use an explicit mapping loop with `index` or `\Q...\E` instead of complex joined regexes to ensure reliable matching of multibyte characters.
- **Inkscape Export ID Limits:** The `inkscape-render.pl` script uses `--export-id print-front --export-id-only`. Any SVG element (like a URL text) that needs to appear on the printed card **must** be nested inside the `<g id="print-front">` group.
- **SVG Structural Editing:** Never use standard XML formatters (like `xmlstarlet` or `xmllint`) to modify Inkscape SVGs. They destroy custom namespaces and formatting, breaking the visual layout.
- **Surgical SVG Node Moving:** To move nodes (like moving the URL inside the print-front group) without breaking the layout, use `scripts/surgical_svg_fix.py`. It uses regex to safely relocate XML blocks and mathematically shift coordinates to account for group transforms.

## Hardware & Environment (klin)
- **Printer Device:** `/dev/usb/lp0`.
- **Printer Reset:** If communication hangs (often due to missing cards or state errors), use `~/klin/Biblio-RFID/reset-printer.sh` on `klin`.
    - Command: `sudo uhubctl -l 3-1.4 -p 1 -a 2`
- **Bidirectional Communication:** The `usblp` driver requires reopening the device between sending commands and reading responses (implemented in `Printer::EVOLIS::Parallel`).
