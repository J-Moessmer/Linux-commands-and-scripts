#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_06_extract_services.sh
# Description:  Extracts the 2nd column (port/protocol) from /etc/services (ignoring
#               comments and empty lines) and saves it to a new file.
# Author:       Tobia / Joshua Mößmer
# Date:         2026-05-18
# ==============================================================================

# Exit on pipeline failure
set -o pipefail

# --- Color Definitions ---
GREEN='\e[1;32m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
NC='\e[0m'

echo -e "${CYAN}=== Task 5: Extract 2nd Column from /etc/services ===${NC}"
echo -e "This script extracts the port/protocol column from the services database.\n"

# Locate services file
SERVICES_FILE=""
for file in "servicesdat" "servicesDat" "assets/servicesdat" "assets/servicesDat" "../assets/servicesdat" "../assets/servicesDat" "../../assets/servicesdat" "../../assets/servicesDat" "/etc/services"; do
    if [ -f "$file" ]; then
        SERVICES_FILE="$file"
        break
    fi
done

if [ -z "$SERVICES_FILE" ]; then
    echo -e "${RED}[Error: Neither servicesDat nor /etc/services was found]${NC}"
    exit 1
fi

# Determine location of the output file
OUTPUT_FILE="services_extracted.txt"
if [ "$(basename "$PWD")" = "scripts" ]; then
    OUTPUT_FILE="../services_extracted.txt"
fi

echo -e "${YELLOW}[Reading from file: $SERVICES_FILE]${NC}"
echo -e "${YELLOW}[Writing to file: $OUTPUT_FILE]${NC}"

# --- Regex & Sed Explanation ---
# Ignore lines starting with '#' (or spaces then '#') and blank lines.
# Keep the second column representing 'port/protocol'.
# Sed expression:
# 1. '/^[[:space:]]*(#|$)/d' -> Deletes blank lines and lines starting with '#'
# 2. 's/^[[:space:]]*[^[:space:]]+[[:space:]]+([^[:space:]]+).*/\1/'
#    - ^[[:space:]]*   -> optional whitespace
#    - [^[:space:]]+   -> service name (first field)
#    - [[:space:]]+    -> separating whitespace
#    - ([^[:space:]]+) -> port/protocol (second field captured into \1)
#    - .*              -> rest of the line (comments, other columns)
# ------------------------------------------------------------------------------

# Execute extraction
sed -E '/^[[:space:]]*(#|$)/d; s/^[[:space:]]*[^[:space:]]+[[:space:]]+([^[:space:]]+).*/\1/' "$SERVICES_FILE" > "$OUTPUT_FILE"

if [ $? -eq 0 ] && [ -s "$OUTPUT_FILE" ]; then
    echo -e "\n${GREEN}Successfully extracted!${NC}"
    echo -e "First 10 lines of the generated file:"
    echo -e "--------------------------------"
    head -n 10 "$OUTPUT_FILE" | sed 's/^/- /'
    total_lines=$(wc -l < "$OUTPUT_FILE")
    echo -e "--------------------------------"
    echo -e "${CYAN}Total lines extracted: $total_lines${NC}"
else
    echo -e "${RED}[Error: Extraction failed or generated file is empty]${NC}"
    exit 1
fi
