#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_02_ipv6.sh
# Description:  Extracts valid IPv6 addresses from the outputs of
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

echo -e "${CYAN}=== Task 1.b: Extract IPv6 Addresses ===${NC}"
echo -e "This script filters valid IPv6 addresses from network configurations.\n"

# --- Regex for standard and compressed IPv6 formats ---
IPV6_REGEX='(([0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|::([0-9a-fA-F]{1,4}:){0,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:(:[0-9a-fA-F]{1,4}){1,6})'

get_input() {
    local cmd="$1"
    local file_base="$2"
    
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
    
    if command -v "${cmd%% *}" >/dev/null 2>&1; then
        echo -e "${GREEN}[Executing live command: $cmd]${NC}" >&2
        eval "$cmd" 2>/dev/null
    else
        echo -e "${RED}[Error: Live command '$cmd' is unavailable and no backup file was found]${NC}" >&2
        return 1
    fi
}

for item in "ifconfig:ifconfig" "ip addr:ip_addr" "ip route:ip_route" "nmcli:nmcli"; do
    IFS=":" read -r cmd file <<< "$item"
    echo -e "\n--- Extracting from: ${CYAN}$cmd${NC} ---"
    
    output=$(get_input "$cmd" "$file")
    if [ $? -eq 0 ] && [ -n "$output" ]; then
        ips=$(echo "$output" | grep -E -o "$IPV6_REGEX" | sort -u)
        if [ -n "$ips" ]; then
            echo -e "${GREEN}$ips${NC}"
        else
            echo "No matching IPv6 addresses found."
        fi
    fi
done
