#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_04_users.sh
# Description:  Extracts usernames from /etc/passwd that have UID >= 1000.
#               Uses regex to identify the UID.
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

echo -e "${CYAN}=== Task 3: Extract Usernames with UID >= 1000 from /etc/passwd ===${NC}"
echo -e "This script reads the user database and filters regular users.\n"

# Locate file (checking backup paths and system file)
PASSWD_FILE=""
for file in "passwddat" "passwdDat" "assets/passwddat" "assets/passwdDat" "../assets/passwddat" "../assets/passwdDat" "../../assets/passwddat" "../../assets/passwdDat" "/etc/passwd"; do
    if [ -f "$file" ]; then
        PASSWD_FILE="$file"
        break
    fi
done

if [ -z "$PASSWD_FILE" ]; then
    echo -e "${RED}[Error: Neither passwdDat nor /etc/passwd was found]${NC}"
    exit 1
fi

echo -e "${YELLOW}[Reading from file: $PASSWD_FILE]${NC}"

# --- Regex Explanation ---
# /etc/passwd structure: username:password:UID:GID:gecos:home:shell
#
# A UID is >= 1000 if it is at least 4 digits long and doesn't start with 0.
# Regex for UID >= 1000: [1-9][0-9]{3,}
# Full line match: ^[^:]+:[^:]+:[1-9][0-9]{3,}:
#   - ^[^:]+         -> Username at start (any character except colon)
#   - :[^:]+         -> Password field (usually 'x')
#   - :[1-9][0-9]{3,}: -> Match UID >= 1000 bordered by colons
# ------------------------------------------------------------------------------

echo -e "\nMatches (Format: Username (UID)):"
echo -e "----------------------------------"

grep -E '^[^:]+:[^:]+:[1-9][0-9]{3,}:' "$PASSWD_FILE" | while read -r line; do
    username=$(echo "$line" | cut -d: -f1)
    uid=$(echo "$line" | cut -d: -f3)
    echo -e "${GREEN}- $username (UID: $uid)${NC}"
done

total=$(grep -E -c '^[^:]+:[^:]+:[1-9][0-9]{3,}:' "$PASSWD_FILE")
echo -e "\n${CYAN}Total regular users found: $total${NC}"
