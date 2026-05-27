#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_10_count_udp.sh
# Description:  Performs port counting analyses for the 'udp' protocol (3-digit,
#               2-digit, and 5-digit) from the extracted services output of Task 5.
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

echo -e "${CYAN}=== Task 9: Count UDP Ports (Similar to Tasks 6 & 7) ===${NC}"
echo -e "Counts 3-digit, as well as 2-digit and 5-digit ports for the 'udp' protocol.\n"

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

# Perform grep counts
count_3=$(grep -E -c '^[0-9]{3}/udp$' "$EXTRACTED_FILE")
count_2=$(grep -E -c '^[0-9]{2}/udp$' "$EXTRACTED_FILE")
count_5=$(grep -E -c '^[0-9]{5}/udp$' "$EXTRACTED_FILE")
count_2_5=$(grep -E -c '^([0-9]{2}|[0-9]{5})/udp$' "$EXTRACTED_FILE")

echo -e "\nResults for UDP:"
echo -e "------------------------------------"
echo -e "${GREEN}- 3-digit UDP ports: $count_3${NC}"
echo -e "${GREEN}- 2-digit UDP ports: $count_2${NC}"
echo -e "${GREEN}- 5-digit UDP ports: $count_5${NC}"
echo -e "------------------------------------"
echo -e "${CYAN}Sum of 2- or 5-digit UDP ports: $count_2_5${NC}"
