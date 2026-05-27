#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_01_ipv4.sh
# Description:  Extracts mathematically valid IPv4 addresses from the outputs of
#               network commands (ifconfig, ip addr, ip route, nmcli) or backup files.
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

echo -e "${CYAN}=== Task 1: Extract IPv4 Addresses ===${NC}"
echo -e "This script filters valid IPv4 addresses from network configurations."
echo -e "It uses a mathematically precise regex to exclude invalid octets (e.g. 999.999.999.999).\n"

# --- Correct Regex for IPv4 Octet (0-255) ---
#   25[0-5]        -> Matches 250 - 255
#   2[0-4][0-9]    -> Matches 200 - 249
#   1[0-9][0-9]    -> Matches 100 - 199
#   [1-9]?[0-9]    -> Matches 0 - 99
IPV4_REGEX='\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\b'

# Helper function to get input (from live command or backup data file)
get_input() {
    local cmd="$1"
    local file_base="$2"
    
    # Path list where backup files might be located
    local search_paths=(
        "$file_base" 
        "assets/$file_base" 
        "../assets/$file_base" 
        "../../assets/$file_base"
        "${file_base}Dat" 
        "assets/${file_base}Dat" 
        "../assets/${file_base}Dat" 
        "../../assets/${file_base}Dat"
        "${file_base}.txt" 
        "assets/${file_base}.txt" 
        "../assets/${file_base}.txt" 
        "../../assets/${file_base}.txt"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -f "$path" ]; then
            echo -e "${YELLOW}[Backup file found: $path]${NC}" >&2
            cat "$path"
            return 0
        fi
    done
    
    # Run the live command if no backup file is present
    if command -v "${cmd%% *}" >/dev/null 2>&1; then
        echo -e "${GREEN}[Executing live command: $cmd]${NC}" >&2
        eval "$cmd" 2>/dev/null
    else
        echo -e "${RED}[Error: Live command '$cmd' is unavailable and no backup file was found]${NC}" >&2
        return 1
    fi
}

# Iterate through the 4 network commands
for item in "ifconfig:ifconfig" "ip addr:ip_addr" "ip route:ip_route" "nmcli:nmcli"; do
    IFS=":" read -r cmd file <<< "$item"
    echo -e "\n--- Extracting from: ${CYAN}$cmd${NC} ---"
    
    output=$(get_input "$cmd" "$file")
    if [ $? -eq 0 ] && [ -n "$output" ]; then
        ips=$(echo "$output" | grep -E -o "$IPV4_REGEX" | sort -u)
        if [ -n "$ips" ]; then
            echo -e "${GREEN}$ips${NC}"
        else
            echo "No matching IPv4 addresses found."
        fi
    fi
done
