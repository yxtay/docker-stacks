#!/bin/bash
set -euo pipefail

# Dokploy Setup Script for Oracle Cloud ARM (Reproducible & Idempotent)

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

# 1. Root Check
if [ "$(id -u)" != "0" ]; then
  printf "%bError: This script must be run as root%b\n" "$RED" "$NC" >&2
  exit 1
fi

# 2. OS Check
if [ -f "/.dockerenv" ] || [ "$(uname)" != "Linux" ]; then
  printf "%bError: This script must be run on a Linux host (not a container)%b\n" "$RED" "$NC" >&2
  exit 1
fi

# 3. Port Check (80, 443, 3000)
for port in 80 443 3000; do
  if ss -tulnp | grep -q ":$port "; then
    printf "%bError: Port $port is already in use. Dokploy requires it to be free.%b\n" "$RED" "$NC" >&2
    exit 1
  fi
done

printf "%bConfiguring Oracle Cloud firewall...%b\n" "$YELLOW" "$NC"

apt-get update
apt-get install -y curl ufw ss-utils || apt-get install -y curl ufw iproute2

ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw allow 3000/tcp || true
ufw allow 2377/tcp || true
ufw allow 7946/tcp || true
ufw allow 7946/udp || true
ufw allow 4789/udp || true
ufw --force enable

printf "%bInstalling Dokploy via official script...%b\n" "$YELLOW" "$NC"
curl -sSL https://dokploy.com/install.sh | sh

printf "%bInstallation complete!%b\n" "$GREEN" "$NC"
