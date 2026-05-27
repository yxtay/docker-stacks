#!/bin/bash

set -e

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
    # OCI Ubuntu images typically have a REJECT rule at the end.
    # We insert after the SSH rule which is typically at position 6.
    # However, to be safer and more idempotent, we can just insert at the top (1)
    # or find the first REJECT rule and insert before it.
    # The user specifically said "after the ssh accept rule".
    # Lets try to find the SSH rule position or default to 6.
    SSH_RULE_POS=$(iptables -L INPUT --line-numbers | grep "tcp dpt:ssh" | awk "{print \$1}" | head -n 1)
    if [ -z "$SSH_RULE_POS" ]; then
      INSERT_POS=1
    else
      INSERT_POS=$((SSH_RULE_POS + 1))
    fi
    iptables -I INPUT "$INSERT_POS" -p "$protocol" --dport "$port" -j ACCEPT
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
  curl -sSL https://dokploy.com/install.sh | bash -s update
else
  echo "Dokploy not found. Installing..."
  curl -sSL https://dokploy.com/install.sh | bash
fi

echo "Init script completed successfully!"
