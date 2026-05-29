#!/usr/bin/env bash
#
# Router / Client Autoconfiguration Script (v2 - JSON configuration)
# Automatically configures network interfaces, forwarding, NAT, and DHCP.
#

set -o pipefail

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: Please run as root (sudo)." >&2
    exit 1
fi

# 1. Detect Linux Distribution and Install Packages (including jq)
echo "Detecting distribution and installing packages..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    OS_ID="unknown"
fi

if [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_ID" == "linuxmint" || -f /etc/debian_version ]]; then
    echo "Detected Debian-based system."
    apt-get update && apt-get install -y dnsmasq iptables-persistent jq
elif [[ "$OS_ID" == "rhel" || "$OS_ID" == "centos" || "$OS_ID" == "rocky" || "$OS_ID" == "almalinux" || -f /etc/redhat-release ]]; then
    echo "Detected RHEL-based system."
    dnf install -y dnsmasq iptables-services jq
    systemctl enable iptables && systemctl start iptables
elif [[ "$OS_ID" == "arch" || "$OS_ID" == "manjaro" || -f /etc/arch-release ]]; then
    echo "Detected Arch-based system."
    pacman -Sy --noconfirm dnsmasq iptables jq
else
    echo "Unknown distribution. Trying to check if required tools are already installed..."
    # Fallback/warning if unknown distribution
    for cmd in dnsmasq iptables jq; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: Required package '$cmd' is missing and distribution package manager is unknown." >&2
            exit 1
        fi
    done
fi

# 2. Configuration Loading
CONFIG_FILE="config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    # Fallback to Config_template.json if config.json is not found
    if [ -f "Config_template.json" ]; then
        echo "Warning: $CONFIG_FILE not found, using Config_template.json instead."
        CONFIG_FILE="Config_template.json"
    else
        echo "Error: Configuration file ($CONFIG_FILE) not found!" >&2
        exit 1
    fi
fi

# Validate jq is available before parsing
if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed. Failed to parse JSON configuration." >&2
    exit 1
fi

# Parse values from JSON configuration
ROLE=$(jq -r '.ROLE // empty' "$CONFIG_FILE")
WAN_IF=$(jq -r '.WAN_IF // empty' "$CONFIG_FILE")
ROUTER_GATEWAY=$(jq -r '.ROUTER_GATEWAY // empty' "$CONFIG_FILE")

# Read arrays from JSON configuration
mapfile -t LAN_IFACES < <(jq -r '.LAN_INTERFACES[].interface // empty' "$CONFIG_FILE")
mapfile -t LAN_IPS < <(jq -r '.LAN_INTERFACES[].ip_address // empty' "$CONFIG_FILE")
mapfile -t DHCP_RANGES < <(jq -r '.LAN_INTERFACES[].dhcp_range // empty' "$CONFIG_FILE")

# Normalize values (strip carriage returns if configuration was edited on Windows)
ROLE=$(echo "$ROLE" | tr -d '\r')
WAN_IF=$(echo "$WAN_IF" | tr -d '\r')
ROUTER_GATEWAY=$(echo "$ROUTER_GATEWAY" | tr -d '\r')

# Validate mandatory configuration parameters
if [[ -z "$ROLE" ]]; then
    echo "Error: ROLE is not specified in the configuration." >&2
    exit 1
fi

# 3. Router vs. Client Logic
if [ "$ROLE" == "router" ]; then
    echo "Configuring system as a Router..."
    
    # Enable IP forwarding
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-router.conf
    sysctl -p /etc/sysctl.d/99-router.conf

    # Check if LAN interfaces were parsed
    if [ ${#LAN_IFACES[@]} -eq 0 ]; then
        echo "Error: No LAN interfaces defined in configuration for router role." >&2
        exit 1
    fi

    # Configure LAN interfaces & IPTables
    for i in "${!LAN_IFACES[@]}"; do
        iface="${LAN_IFACES[$i]}"
        ip_addr="${LAN_IPS[$i]}"
        
        if [[ -z "$iface" || -z "$ip_addr" ]]; then
            echo "Warning: Missing interface or IP address at index $i, skipping..."
            continue
        fi

        echo "Configuring interface $iface with IP $ip_addr..."
        ip addr add "$ip_addr" dev "$iface" 2>/dev/null || true
        ip link set "$iface" up

        if [[ -n "$WAN_IF" ]]; then
            echo "Adding iptables NAT rule for $iface -> $WAN_IF..."
            iptables -t nat -A POSTROUTING -o "$WAN_IF" -j MASQUERADE
        fi
    done

    # Configure dnsmasq DHCP server
    # Format interfaces string: "interface=eth1 eth2"
    ifaces_list=$(printf "interface=%s\n" "${LAN_IFACES[@]}")
    echo -e "$ifaces_list\n" > /etc/dnsmasq.conf
    
    for i in "${!LAN_IFACES[@]}"; do
        range="${DHCP_RANGES[$i]}"
        if [[ -n "$range" && "$range" != "null" ]]; then
            echo "dhcp-range=$range" >> /etc/dnsmasq.conf
        fi
    done

    echo "Restarting dnsmasq service..."
    systemctl restart dnsmasq
    systemctl enable dnsmasq

elif [ "$ROLE" == "client" ]; then
    echo "Configuring system as a Client..."
    
    if [ ${#LAN_IFACES[@]} -eq 0 ]; then
        echo "Error: No interfaces defined in configuration for client role." >&2
        exit 1
    fi

    client_iface="${LAN_IFACES[0]}"
    echo "Setting link up on interface: $client_iface"
    ip link set "$client_iface" up

    if [[ -n "$ROUTER_GATEWAY" ]]; then
        echo "Setting default gateway to $ROUTER_GATEWAY..."
        ip route add default via "$ROUTER_GATEWAY" 2>/dev/null || true
    else
        echo "Warning: ROUTER_GATEWAY not specified in configuration."
    fi
else
    echo "Error: Unknown role '$ROLE'. Valid values are 'router' or 'client'." >&2
    exit 1
fi

echo "Setup completed successfully!"