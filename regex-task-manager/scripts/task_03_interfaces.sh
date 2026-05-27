#!/usr/bin/env bash

# ==============================================================================
# Script Name:  task_03_interfaces.sh
# Description:  Extracts network interface names from the outputs of
#               network commands (ifconfig, nmcli, ip addr, ip route) or backup files.
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

echo -e "${CYAN}=== Task 2: Extract Network Interfaces ===${NC}"
echo -e "This script filters network interface names from various configurations.\n"

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

# 1. ifconfig
echo -e "--- Extracting from: ${CYAN}ifconfig${NC} ---"
output_ifconfig=$(get_input "ifconfig" "ifconfig")
if [ $? -eq 0 ] && [ -n "$output_ifconfig" ]; then
    # In ifconfig, interface names start at the beginning of the line followed by a colon
    interfaces=$(echo "$output_ifconfig" | grep -E -o '^[a-zA-Z0-9_-]+:' | tr -d ':' | sort -u)
    if [ -n "$interfaces" ]; then
        echo -e "${GREEN}$interfaces${NC}"
    else
        echo "No interfaces found."
    fi
fi

# 2. ip addr
echo -e "\n--- Extracting from: ${CYAN}ip addr${NC} ---"
output_ipaddr=$(get_input "ip addr" "ip_addr")
if [ $? -eq 0 ] && [ -n "$output_ipaddr" ]; then
    # In ip addr, interfaces are shown in the format: "2: enp0s3: <BROADCAST..."
    interfaces=$(echo "$output_ipaddr" | grep -E -o '^[0-9]+: [a-zA-Z0-9_-]+:' | awk -F': ' '{print $2}' | sort -u)
    if [ -n "$interfaces" ]; then
        echo -e "${GREEN}$interfaces${NC}"
    else
        echo "No interfaces found."
    fi
fi

# 3. ip route
echo -e "\n--- Extracting from: ${CYAN}ip route${NC} ---"
output_iproute=$(get_input "ip route" "ip_route")
if [ $? -eq 0 ] && [ -n "$output_iproute" ]; then
    # In ip route, interface names follow the keyword "dev"
    interfaces=$(echo "$output_iproute" | grep -E -o '\bdev\s+[a-zA-Z0-9_-]+' | awk '{print $2}' | sort -u)
    if [ -n "$interfaces" ]; then
        echo -e "${GREEN}$interfaces${NC}"
    else
        echo "No interfaces found."
    fi
fi

# 4. nmcli
echo -e "\n--- Extracting from: ${CYAN}nmcli${NC} ---"
output_nmcli=$(get_input "nmcli" "nmcli")
if [ $? -eq 0 ] && [ -n "$output_nmcli" ]; then
    # Check if table header format exists
    if echo "$output_nmcli" | grep -q '^DEVICE'; then
        # Print first column, skipping header line
        interfaces=$(echo "$output_nmcli" | awk 'NR>1 {print $1}' | sort -u)
    else
        # Standard nmcli connection output shows "eth0: connected to..."
        interfaces=$(echo "$output_nmcli" | grep -E -o '^[a-zA-Z0-9_-]+:' | tr -d ':' | sort -u)
    fi
    if [ -n "$interfaces" ]; then
        echo -e "${GREEN}$interfaces${NC}"
    else
        echo "No interfaces found."
    fi
fi
