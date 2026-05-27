#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_08_count_2_5digit_tcp.sh
# Description:  Filters and counts 2-digit and 5-digit port numbers using the
#               'tcp' protocol from the extracted services output of Task 5.
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

echo -e "${CYAN}=== Task 7: Count 2- and 5-Digit TCP Ports ===${NC}"
echo -e "Filters and counts ports matching XX/tcp (2 digits) or XXXXX/tcp (5 digits).\n"

# Locate the extracted services file
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
# Match exactly 2 or 5 digits and 'tcp' protocol.
# Regex: ^([0-9]{2}|[0-9]{5})/tcp$
# - ^                 -> Start of line
# - (                 -> Alternation block start
#   - [0-9]{2}        -> Exactly 2 digits
#   - |               -> OR operator
#   - [0-9]{5}        -> Exactly 5 digits
# - )                 -> Alternation block end
# - /tcp              -> Protocol literal
# - $                 -> End of line
# ------------------------------------------------------------------------------

# Count 2-digit ports
count_2=$(grep -E -c '^[0-9]{2}/tcp$' "$EXTRACTED_FILE")
# Count 5-digit ports
count_5=$(grep -E -c '^[0-9]{5}/tcp$' "$EXTRACTED_FILE")
# Count total combination
count_total=$(grep -E -c '^([0-9]{2}|[0-9]{5})/tcp$' "$EXTRACTED_FILE")

echo -e "\nResults:"
echo -e "------------------------------------"
echo -e "${GREEN}- 2-digit TCP ports: $count_2${NC}"
echo -e "${GREEN}- 5-digit TCP ports: $count_5${NC}"
echo -e "------------------------------------"
echo -e "${CYAN}Total count (2- or 5-digit): $count_total${NC}"
