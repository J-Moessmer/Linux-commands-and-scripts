#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_09_unique_protocols.sh
# Description:  Identifies and counts unique transport protocols (e.g. tcp, udp,
#               sctp) from the extracted services output of Task 5.
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

echo -e "${CYAN}=== Task 8: Count Unique Transport Protocols ===${NC}"
echo -e "Extracts and counts all unique protocols (e.g., tcp, udp, sctp).\n"

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

# --- Regex & Pipeline Explanation ---
# Each line in services_extracted.txt follows the 'port/protocol' format.
#
# Pipeline steps:
# 1. grep -E -o '[a-zA-Z0-9_-]+$'
#    - Extracts only the protocol name (word matching after slash at line end)
# 2. sort -u
#    - Sorts alphabetically and removes duplicates (-u stands for unique)
# ------------------------------------------------------------------------------

echo -e "\nUnique Transport Protocols Found:"
echo -e "-------------------------------------------"

# Extract, deduplicate, and print protocols
protocols=$(grep -E -o '[a-zA-Z0-9_-]+$' "$EXTRACTED_FILE" | sort -u)
echo -e "${GREEN}$protocols${NC}"

# Count unique lines
count=$(echo "$protocols" | wc -l)

echo -e "-------------------------------------------"
echo -e "${CYAN}Total number of distinct protocols: $count${NC}"
