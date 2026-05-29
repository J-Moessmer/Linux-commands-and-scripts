#!/bin/bash
if [[ $EUID -ne 0 ]]; then echo "Please run as root"; exit 1; fi

# 1. Konfiguration laden
CONFIG_FILE="config.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found!"
    exit 1
fi

# read config file without leading #
source <(grep -v '^#' "$CONFIG_FILE" | grep -v '^$')

# 2. detect Linux distro and install packages
echo "Detecting distribution..."
if [ -f /etc/debian_version ]; then
    # Debian/Mint
    apt update && apt install -y dnsmasq iptables-persistent
elif [ -f /etc/redhat-release ]; then
    # Rocky/RHEL
    dnf install -y dnsmasq iptables-services
    systemctl enable iptables && systemctl start iptables
elif [ -f /etc/arch-release ]; then
    # Manjaro/Cachy/Arch
    pacman -Sy --noconfirm dnsmasq iptables
fi


# 3. Router vs. Client Logic
if [ "$ROLE" == "router" ]; then
    echo "Configuring as Router..."
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-router.conf
    sysctl -p /etc/sysctl.d/99-router.conf
    
    for i in "${!LAN_IFACES[@]}"; do
        ip addr add ${LAN_IPS[$i]} dev ${LAN_IFACES[$i]}
        ip link set ${LAN_IFACES[$i]} up
        iptables -t nat -A POSTROUTING -o $WAN_IF -j MASQUERADE
    done

    # Dnsmasq
    echo -e "interface=${LAN_IFACES[@]}\n" > /etc/dnsmasq.conf
    for i in "${!LAN_IFACES[@]}"; do
        echo "dhcp-range=${DHCP_RANGES[$i]}" >> /etc/dnsmasq.conf
    done
    systemctl restart dnsmasq
    systemctl enable dnsmasq

elif [ "$ROLE" == "client" ]; then
    echo "Configuring as Client..."
    # Client uses only the first interface from the list
    ip link set ${LAN_IFACES[0]} up
    # Set default gateway (IP of the router)
    ip route add default via $ROUTER_GATEWAY
fi

echo "Setup completed!"