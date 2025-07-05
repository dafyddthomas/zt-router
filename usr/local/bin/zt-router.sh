#!/bin/bash
set -e
CONFIG_FILE="/etc/zt-router.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then echo "❌ Config file not found: $CONFIG_FILE"; exit 1; fi
source "$CONFIG_FILE"
if [[ -z "$ZT_SUBNET" || -z "$LAN_IFACE" || -z "$LAN_SUBNETS" ]]; then echo "❌ ZT_SUBNET, LAN_IFACE, and LAN_SUBNETS must be defined"; exit 1; fi
MAX_RETRIES=10; RETRY_DELAY=2; ZT_IFACE=""
for ((i=1; i<=MAX_RETRIES; i++)); do
  ZT_IFACE=$(ip -o link show | grep 'zt' | awk -F': ' '{print $2}' | head -n1)
  [[ -n "$ZT_IFACE" ]] && break
  sleep $RETRY_DELAY
done
[[ -z "$ZT_IFACE" ]] && echo "❌ ZeroTier interface not found" && exit 1
sysctl -w net.ipv4.ip_forward=1
sed -i 's/^#*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
iptables -F; iptables -t nat -F
for SUBNET in $LAN_SUBNETS; do
  iptables -t nat -A POSTROUTING -s "$SUBNET" -o "$ZT_IFACE" -j MASQUERADE
  iptables -A FORWARD -i "$LAN_IFACE" -o "$ZT_IFACE" -s "$SUBNET" -d "$ZT_SUBNET" -j ACCEPT
  iptables -A FORWARD -i "$ZT_IFACE" -o "$LAN_IFACE" -s "$ZT_SUBNET" -d "$SUBNET" -j ACCEPT
done
iptables-save > /etc/iptables/rules.v4
echo "✅ Routing active between LAN and $ZT_SUBNET"
