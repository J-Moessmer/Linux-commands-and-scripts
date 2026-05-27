#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_05_groups.sh
# Description:  Extracts group names from /etc/group that have GID >= 1000.
#               Uses regex to identify the GID.
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

echo -e "${CYAN}=== Task 4: Extract Group Names with GID >= 1000 from /etc/group ===${NC}"
echo -e "This script reads the group database and filters regular groups.\n"

# Locate file
GROUP_FILE=""
for file in "groupdat" "groupDat" "assets/groupdat" "assets/groupDat" "../assets/groupdat" "../assets/groupDat" "../../assets/groupdat" "../../assets/groupDat" "/etc/group"; do
    if [ -f "$file" ]; then
        GROUP_FILE="$file"
        break
    fi
done

if [ -z "$GROUP_FILE" ]; then
    echo -e "${RED}[Error: Neither groupdat nor /etc/group was found]${NC}"
    exit 1
fi

echo -e "${YELLOW}[Reading from file: $GROUP_FILE]${NC}"

# --- Regex Explanation ---
# /etc/group structure: groupname:password:GID:user_list
#
# A GID is >= 1000 if it is at least 4 digits long and doesn't start with 0.
# Regex for GID >= 1000: [1-9][0-9]{3,}
# Full line match: ^[^:]+:[^:]+:[1-9][0-9]{3,}:
#   - ^[^:]+         -> Group name at start
#   - :[^:]+         -> Password field (usually 'x' or empty)
#   - :[1-9][0-9]{3,}: -> Match GID >= 1000 bordered by colons
# ------------------------------------------------------------------------------

echo -e "\nMatches (Format: Group Name (GID)):"
echo -e "------------------------------------"

grep -E '^[^:]+:[^:]+:[1-9][0-9]{3,}:' "$GROUP_FILE" | while read -r line; do
    groupname=$(echo "$line" | cut -d: -f1)
    gid=$(echo "$line" | cut -d: -f3)
    echo -e "${GREEN}- $groupname (GID: $gid)${NC}"
done

total=$(grep -E -c '^[^:]+:[^:]+:[1-9][0-9]{3,}:' "$GROUP_FILE")
echo -e "\n${CYAN}Total regular groups found: $total${NC}"
