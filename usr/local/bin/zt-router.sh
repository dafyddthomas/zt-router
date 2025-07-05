#!/bin/bash

set -e

CONFIG_FILE="/etc/zt-router.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

source "$CONFIG_FILE"

if [[ -z "$ZT_SUBNET" || -z "$LAN_IFACE" || -z "$LAN_SUBNETS" ]]; then
  echo "❌ ZT_SUBNET, LAN_IFACE, and LAN_SUBNETS must be defined in $CONFIG_FILE"
  exit 1
fi

# Retry logic for ZeroTier interface
MAX_RETRIES=10
RETRY_DELAY=2
ZT_IFACE=""

echo "🔍 Detecting ZeroTier interface..."
for ((i=1; i<=MAX_RETRIES; i++)); do
  ZT_IFACE=$(ip -o link show | grep 'zt' | awk -F': ' '{print $2}' | head -n1)
  if [[ -n "$ZT_IFACE" ]]; then
    echo "✅ Found ZeroTier interface: $ZT_IFACE"
    break
  fi
  echo "⏳ Attempt $i/$MAX_RETRIES: Waiting for ZeroTier interface..."
  sleep $RETRY_DELAY
done

if [[ -z "$ZT_IFACE" ]]; then
  echo "❌ Failed to detect ZeroTier interface after $MAX_RETRIES tries"
  exit 1
fi

# Enable IP forwarding
echo "📡 Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
sed -i 's/^#*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Flush and apply iptables rules
echo "🧹 Flushing old iptables rules..."
iptables -F
iptables -t nat -F

echo "🌐 Applying NAT and forwarding rules for LAN subnets:"
for SUBNET in $LAN_SUBNETS; do
  echo "  ➤ $SUBNET"
  iptables -t nat -A POSTROUTING -s "$SUBNET" -o "$ZT_IFACE" -j MASQUERADE
  iptables -A FORWARD -i "$LAN_IFACE" -o "$ZT_IFACE" -s "$SUBNET" -d "$ZT_SUBNET" -j ACCEPT
  iptables -A FORWARD -i "$ZT_IFACE" -o "$LAN_IFACE" -s "$ZT_SUBNET" -d "$SUBNET" -j ACCEPT
done

# Save rules
echo "💾 Saving iptables rules..."
iptables-save > /etc/iptables/rules.v4

echo "✅ Routing is active between LAN subnets and $ZT_SUBNET via $ZT_IFACE"
