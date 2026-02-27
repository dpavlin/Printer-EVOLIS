#!/usr/bin/env python3
import re
import sys

def fix_svg(input_path, output_path):
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Extract the Text_Front_URL node (including everything up to </text>)
    # Handle both <text> and <svg:text> styles
    text_pattern = re.compile(r'(<(?:svg:)?text\b[^>]*?id="Text_Front_URL"[^>]*>.*?</(?:svg:)?text>)', re.DOTALL)
    match = text_pattern.search(content)

    if not match:
        print("Error: Could not find <text id=\"Text_Front_URL\"> in the SVG.")
        sys.exit(1)

    url_block = match.group(1)

    # 2. Remove the block from its original location
    content = content.replace(url_block, '')

    # 3. Adjust all x and y coordinates inside the block by (-8, -10).
    def adjust_x(m):
        new_val = float(m.group(1)) - 8
        return f'x="{new_val:g}{m.group(2)}"'

    def adjust_y(m):
        new_val = float(m.group(1)) - 10
        return f'y="{new_val:g}{m.group(2)}"'

    modified_block = re.sub(r'x="([0-9.-]+)([a-zA-Z%]*)"', adjust_x, url_block)
    modified_block = re.sub(r'y="([0-9.-]+)([a-zA-Z%]*)"', adjust_y, modified_block)

    # 4. Find the print-front group to insert into
    group_pattern = re.compile(r'(<(?:svg:)?g\b[^>]*?id="print-front"[^>]*>)')
    group_match = group_pattern.search(content)

    if not group_match:
        print("Error: Could not find <g id=\"print-front\"> in the SVG.")
        sys.exit(1)

    group_start = group_match.group(1)
    
    # 5. Insert the modified URL block immediately after the <g> tag opening
    replacement = group_start + '\n    ' + modified_block
    content = content.replace(group_start, replacement, 1)

    # 6. Save the surgical edit
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Success: Text_Front_URL moved into print-front group and coordinates shifted.")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python surgical_svg_fix.py <input.svg> <output.svg>")
        sys.exit(1)
    fix_svg(sys.argv[1], sys.argv[2])
