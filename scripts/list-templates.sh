#!/bin/bash

# Script to list all SVG templates and detect if they are single or double sided

RENDER="./scripts/inkscape-render.pl"
mkdir -p out

echo -e "Template			Type		Front	Back"
echo -e "------------------------------------------------------------"

for svg in card/*.svg; do
    name=$(basename "$svg")
    nr="list-test-${name%.*}"
    
    # Render the template
    $RENDER "$svg" "$nr" "200908109999" "test" "user" > /dev/null 2>&1
    
    front="out/$nr.front.pbm"
    back="out/$nr.back.pbm"
    
    front_status="BLANK"
    back_status="BLANK"
    type="Single"
    
    if [ -f "$front" ]; then
        if sed '1,3d' "$front" | grep -qP '[^\x00]'; then
            front_status="CONTENT"
        fi
    fi
    
    if [ -f "$back" ]; then
        if sed '1,3d' "$back" | grep -qP '[^\x00]'; then
            back_status="CONTENT"
            type="Double"
        fi
    fi
    
    printf "%-31s %-15s %-7s %-7s
" "$name" "$type" "$front_status" "$back_status"
done
