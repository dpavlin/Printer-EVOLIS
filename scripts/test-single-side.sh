#!/bin/bash

# Test script for automatic single-sided printing logic

RENDER="./scripts/inkscape-render.pl"
DRIVER="./scripts/evolis-driver.pl"
SIMULATOR="./scripts/evolis-simulator.pl"

test_svg() {
    local svg=$1
    local name=$(basename "$svg" .svg)
    local nr="test-$name"
    
    echo "--- Testing $svg ---"
    
    # 1. Render
    $RENDER "$svg" "$nr" testuser "Test" "User"
    
    local front="out/$nr.front.pbm"
    local back="out/$nr.back.pbm"
    local evolis="out/$nr.evolis"
    
    # 2. Analyze PBM content
    echo "Analyzing PBM content..."
    # Skip header: P4, optional comments, width height
    # dimens=$(head -n 3 "$front" | grep -v '^#' | tail -n 1)
    
    # Simpler: use the same regex as the driver on the whole file, 
    # but excluding the first few bytes which are ASCII.
    # Or just use the driver's own read_pbm logic if we were in perl.
    # In bash, we can use sed to remove the first 3 lines (typical P4 header).
    
    if sed '1,3d' "$front" | grep -qP '[^\x00]'; then
        echo "  Front side: HAS CONTENT (OK)"
    else
        echo "  Front side: BLANK (Unexpected)"
    fi
    
    local back_blank=0
    if sed '1,3d' "$back" | grep -qP '[^\x00]'; then
        echo "  Back side: HAS CONTENT"
    else
        echo "  Back side: BLANK"
        back_blank=1
    fi
    
    # 3. Run Driver
    echo "Running driver..."
    $DRIVER "$front" "$back" > "$evolis" 2> "$evolis.log"
    cat "$evolis.log"
    
    if [ $back_blank -eq 1 ]; then
        if grep -q "back side is blank, skipping" "$evolis.log"; then
            echo "  Driver: Detected blank back and skipped (OK)"
        else
            echo "  Driver: FAILED to detect blank back"
        fi
    else
        if grep -q "back side is blank, skipping" "$evolis.log"; then
            echo "  Driver: FAILED (skipped non-blank back)"
        else
            echo "  Driver: Processed both sides (OK)"
        fi
    fi
    
    # 4. Verify with Simulator
    echo "Verifying with simulator..."
    rm -f "$evolis"-Db-k-*.pbm
    $SIMULATOR "$evolis" > /dev/null 2>&1
    
    local pbm_count=$(ls "$evolis"-Db-k-*.pbm 2>/dev/null | wc -l)
    echo "  Simulator produced $pbm_count bitmap(s)"
    
    if [ $back_blank -eq 1 ] && [ "$pbm_count" -eq 1 ]; then
        echo "  Simulation: Correctly produced only one side (OK)"
    elif [ $back_blank -eq 0 ] && [ "$pbm_count" -eq 2 ]; then
        echo "  Simulation: Correctly produced both sides (OK)"
    else
        echo "  Simulation: FAILED (count=$pbm_count, expected=$((2-back_blank)))"
    fi
    echo ""
}

# Ensure out directory exists
mkdir -p out

# Test known double-sided
test_svg "card/ffzg-2010.svg"

# Test new 2026 v3 single-sided
test_svg "card/ffzg-2026-v3-single-side.svg"

# Test known single-sided (renders blank back)
test_svg "card/ffzg-2018-old-cards.svg"
