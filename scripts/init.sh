#!/bin/bash

set -euo pipefaile

echo "Updating and upgrading packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

echo "Configuring iptables..."

# Function to add iptables rule if it doesnt exist
add_port_rule() {
  local port=$1
  local protocol=$2
  if ! iptables -C INPUT -p "$protocol" --dport "$port" -j ACCEPT 2>/dev/null; then
    echo "Adding rule for port $port/$protocol"
    # Insert at the top (position 1) to ensure it precedes any REJECT rules
    iptables -I INPUT 1 -p "$protocol" --dport "$port" -j ACCEPT
  else
    echo "Rule for port $port/$protocol already exists"
  fi
}

add_port_rule 80 tcp
add_port_rule 443 tcp
add_port_rule 443 udp
add_port_rule 3000 tcp

# Make iptables persistent
echo "Ensuring iptables persistence..."
if ! command -v netfilter-persistent >/dev/null 2>&1; then
  apt-get install -y iptables-persistent
fi
netfilter-persistent save

echo "Handling Dokploy installation/update..."

if command -v docker >/dev/null 2>&1 && docker service inspect dokploy >/dev/null 2>&1; then
  echo "Dokploy is already installed. Updating..."
  # nosemgrep: bash.curl.security.curl-pipe-bash.curl-pipe-bash
  curl -sSL https://dokploy.com/install.sh | bash -s update
else
  echo "Dokploy not found. Installing..."
  curl -sSL https://dokploy.com/install.sh | bash
fi

echo "Init script completed successfully!"
