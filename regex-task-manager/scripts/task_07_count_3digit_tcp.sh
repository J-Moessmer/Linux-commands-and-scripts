#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_07_count_3digit_tcp.sh
# Description:  Filters and counts all 3-digit port numbers using the 'tcp'
#               protocol from the extracted services output of Task 5.
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

echo -e "${CYAN}=== Task 6: Count 3-Digit TCP Ports ===${NC}"
echo -e "Filters and counts ports in the format XXX/tcp (exactly 3 digits).\n"

# Locate the extracted services file from Task 5
EXTRACTED_FILE=""
for file in "services_extracted.txt" "../services_extracted.txt" "assets/services_extracted.txt" "../assets/services_extracted.txt" "../../services_extracted.txt" "../../assets/services_extracted.txt"; do
    if [ -f "$file" ]; then
        EXTRACTED_FILE="$file"
        break
    fi
done

if [ -z "$EXTRACTED_FILE" ] || [ ! -s "$EXTRACTED_FILE" ]; then
    echo -e "${RED}[Error: 'services_extracted.txt' not found or is empty.]${NC}"
    echo -e "${YELLOW}Please run Task 5 (services extraction) first!${NC}"
    exit 1
fi

echo -e "${YELLOW}[Reading from file: $EXTRACTED_FILE]${NC}"

# --- Regex Explanation ---
# Match exactly 3 digits followed by '/tcp'
# Regex: ^[0-9]{3}/tcp$
# - ^         -> Start of line
# - [0-9]{3}  -> Exactly 3 digits (000 to 999)
# - /tcp      -> Protocol literal '/tcp'
# - $         -> End of line
# ------------------------------------------------------------------------------

# Show sample matches
echo -e "\nSample matches (first 10):"
echo -e "------------------------------------"
grep -E '^[0-9]{3}/tcp$' "$EXTRACTED_FILE" | head -n 10 | sed 's/^/- /'

# Count total matches
count=$(grep -E -c '^[0-9]{3}/tcp$' "$EXTRACTED_FILE")

echo -e "------------------------------------"
echo -e "${GREEN}Total 3-digit TCP ports found: $count${NC}"
