#!/bin/bash

# Script to render a card template with the background layer visible for preview
# Usage: ./scripts/render-preview.sh card/template.svg [output.png]

INPUT_SVG=$1
OUTPUT_PNG=${2:-out/preview.png}

if [ -z "$INPUT_SVG" ]; then
    echo "Usage: $0 <input_svg> [output_png]"
    exit 1
fi

TEMP_SVG=$(mktemp --suffix=.svg)

# Copy and enable the background layer (label="offset")
perl -0777 -pe 's/(inkscape:label="offset".*?)style="display:none"/$1style="display:inline"/s' "$INPUT_SVG" > "$TEMP_SVG"

echo "Rendering $INPUT_SVG with background to $OUTPUT_PNG..."
inkscape --export-type=png --export-dpi=300 --export-filename="$OUTPUT_PNG" "$TEMP_SVG"

rm "$TEMP_SVG"
