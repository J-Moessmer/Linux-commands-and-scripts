#!/usr/bin/env bash

# ==============================================================================
# Script Name:  validate_ipv6.sh
# Description:  Validates if an input string is a valid IPv6 address using regex.
#               Supports standard and compressed IPv6 formats.
#               Can read input from a CLI argument or an interactive prompt.
# Author:       Joshua Mößmer
# Date:         2026-05-18
# ==============================================================================

# IPv6 Regex pattern matching standard and compressed variants
REGEX="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"

IP=""

# Check if command line argument is provided
if [ $# -gt 0 ]; then
    IP="$1"
else
    # Fallback to interactive input prompt
    read -p "Please enter an IPv6 address to validate: " IP
fi

# Trim whitespace
IP=$(echo "$IP" | xargs)

# Exit if input is empty
if [ -z "$IP" ]; then
    echo "Error: No address was entered."
    exit 1
fi

# Validation Check
if [[ "$IP" =~ $REGEX ]]; then
    echo -e "✅ '$IP' is a VALID IPv6 address."
    exit 0
else
    echo -e "❌ '$IP' is an INVALID IPv6 address."
    exit 1
fi
