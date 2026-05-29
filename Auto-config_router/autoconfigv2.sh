#!/usr/bin/env bash
#
# Router / Client Autoconfiguration Script (v2.2 - Dynamic MAC inside interface objects)
# Automatically configures network interfaces, forwarding, NAT, and DHCP.
# Updates Config.json with local MAC addresses inside interface objects.
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
    for cmd in dnsmasq iptables jq; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: Required package '$cmd' is missing and distribution package manager is unknown." >&2
            exit 1
        fi
    done
fi

# 2. Configuration File Resolution
CONFIG_FILE="Config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    if [ -f "Config_template.json" ]; then
        echo "Warning: $CONFIG_FILE not found, copying from Config_template.json."
        cp Config_template.json "$CONFIG_FILE"
    else
        echo "Error: Configuration file ($CONFIG_FILE) not found!" >&2
        exit 1
    fi
fi

# Validate jq is available
if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed. Failed to parse JSON configuration." >&2
    exit 1
fi

# 3. Read and Update Local MAC Addresses inside interface objects in the JSON Configuration
echo "Checking and updating MAC addresses for local interfaces in $CONFIG_FILE..."
while read -r node iface; do
    if [ -f "/sys/class/net/$iface/address" ]; then
        mac=$(cat "/sys/class/net/$iface/address" | tr -d '\r')
        echo "Detected interface $iface for host node '$node' with MAC: $mac"
        
        # Check if the node has 'interfaces' (router array of objects) or single 'interface' (client object)
        if jq -e ".[\"$node\"] | has(\"interfaces\")" "$CONFIG_FILE" >/dev/null 2>&1; then
            idx=$(jq -r ".[\"$node\"].interfaces | map(.name) | index(\"$iface\")" "$CONFIG_FILE")
            if [[ "$idx" != "null" ]]; then
                jq --arg node "$node" --argjson idx "$idx" --arg mac "$mac" '.[$node].interfaces[$idx].mac = $mac' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
            fi
        else
            jq --arg node "$node" --arg mac "$mac" '.[$node].interface.mac = $mac' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        fi
    fi
done < <(jq -r 'to_entries[] | .key as $node | (if .value.interface.name != null then "\($node) \(.value.interface.name)" else empty end), (if .value.interfaces != null then "\($node) \(.value.interfaces[].name)" else empty end)' "$CONFIG_FILE")

# 4. Determine Active Node to Configure
NODE="${1:-}"
if [[ -z "$NODE" ]]; then
    # Try to match current hostname with a key in Config.json
    curr_hostname=$(hostname | tr -d '\r')
    if jq -e "has(\"$curr_hostname\")" "$CONFIG_FILE" >/dev/null 2>&1; then
        NODE="$curr_hostname"
        echo "Auto-detected node matching hostname: '$NODE'"
    else
        NODE="router"
        echo "No specific node argument provided and hostname '$curr_hostname' not found in config. Defaulting to '$NODE'."
    fi
fi

if ! jq -e "has(\"$NODE\")" "$CONFIG_FILE" >/dev/null 2>&1; then
    echo "Error: Node '$NODE' is not defined in $CONFIG_FILE" >&2
    exit 1
fi

ROLE=$(jq -r ".[\"$NODE\"].role // empty" "$CONFIG_FILE" | tr -d '\r')
if [[ -z "$ROLE" ]]; then
    echo "Error: role is not defined for node '$NODE' in $CONFIG_FILE" >&2
    exit 1
fi

# 5. Router vs. Client Logic
if [ "$ROLE" == "router" ]; then
    echo "Configuring node '$NODE' as a Router..."
    
    # Enable IP forwarding
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-router.conf
    sysctl -p /etc/sysctl.d/99-router.conf

    # Read configuration arrays
    mapfile -t LAN_IFACES < <(jq -r ".[\"$NODE\"].interfaces[].name // empty" "$CONFIG_FILE" | tr -d '\r')
    mapfile -t LAN_IPS < <(jq -r ".[\"$NODE\"].ips[] // empty" "$CONFIG_FILE" | tr -d '\r')
    mapfile -t DHCP_RANGES < <(jq -r ".[\"$NODE\"].dhcp[] // empty" "$CONFIG_FILE" | tr -d '\r')

    if [ ${#LAN_IFACES[@]} -eq 0 ]; then
        echo "Error: No interfaces defined for router node '$NODE'." >&2
        exit 1
    fi

    # Configure LAN interfaces & iptables masquerade
    for i in "${!LAN_IFACES[@]}"; do
        iface="${LAN_IFACES[$i]}"
        ip_addr="${LAN_IPS[$i]}"
        
        if [[ -z "$iface" || -z "$ip_addr" ]]; then
            continue
        fi

        echo "Configuring interface $iface with IP $ip_addr..."
        ip addr add "$ip_addr" dev "$iface" 2>/dev/null || true
        ip link set "$iface" up
    done

    # Setup NAT
    if [ ${#LAN_IFACES[@]} -gt 1 ]; then
        WAN_IF="${LAN_IFACES[0]}"
        for ((i=1; i<${#LAN_IFACES[@]}; i++)); do
            lan_if="${LAN_IFACES[$i]}"
            echo "Adding iptables NAT rule for $lan_if -> $WAN_IF..."
            iptables -t nat -A POSTROUTING -o "$WAN_IF" -j MASQUERADE
        done
    fi

    # Configure dnsmasq DHCP server
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
    echo "Configuring node '$NODE' as a Client..."
    
    client_iface=$(jq -r ".[\"$NODE\"].interface.name // empty" "$CONFIG_FILE" | tr -d '\r')
    client_ip=$(jq -r ".[\"$NODE\"].ip // empty" "$CONFIG_FILE" | tr -d '\r')
    gateway=$(jq -r ".[\"$NODE\"].gateway // empty" "$CONFIG_FILE" | tr -d '\r')

    if [[ -z "$client_iface" ]]; then
        echo "Error: No interface defined for client node '$NODE'." >&2
        exit 1
    fi

    echo "Configuring interface $client_iface with IP $client_ip..."
    if [[ -n "$client_ip" ]]; then
        ip addr add "$client_ip" dev "$client_iface" 2>/dev/null || true
    fi
    ip link set "$client_iface" up

    if [[ -n "$gateway" ]]; then
        echo "Setting default gateway to $gateway..."
        ip route add default via "$gateway" 2>/dev/null || true
    fi
else
    echo "Error: Unknown role '$ROLE'. Valid values are 'router' or 'client'." >&2
    exit 1
fi

echo "Setup completed successfully for node '$NODE'!"