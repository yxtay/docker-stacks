#!/bin/bash
set -euo pipefail

echo "Upgrading and installing packages..."
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
apt-get update
apt-get upgrade --yes
apt-get install --yes --no-install-recommends iptables-persistent

echo "Configuring iptables..."

# Function to add iptables rule if it doesnt exist
add_port_rule() {
  local port=$1
  local protocol=$2
  if ! iptables --check INPUT --protocol "$protocol" --dport "$port" --jump ACCEPT 2>/dev/null; then
    echo "Adding rule for port $port/$protocol"
    # Insert at the top to ensure it precedes any REJECT rules
    iptables --insert INPUT --protocol "$protocol" --dport "$port" --jump ACCEPT
  else
    echo "Rule for port $port/$protocol already exists"
  fi
}

add_port_rule 80 tcp
add_port_rule 443 tcp
add_port_rule 443 udp
add_port_rule 3000 tcp

# Make iptables persistent
netfilter-persistent save

echo "Handling Dokploy installation/update..."
# https://docs.dokploy.com/docs/core/installation

install_args=""
if command -v docker >/dev/null 2>&1 &&
  docker ps --filter name=dokploy --format '{{.Names}}' 2>/dev/null | grep --quiet "dokploy"; then
  echo "Dokploy is already installed. Updating..."
  install_args="update"
else
  echo "Dokploy not found. Installing..."
fi
# nosemgrep: bash.curl.security.curl-pipe-bash.curl-pipe-bash
curl -fsSL https://dokploy.com/install.sh | bash -s $install_args

echo "Init script completed successfully!"
