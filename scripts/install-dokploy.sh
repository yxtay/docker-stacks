#!/bin/bash
set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

printf "%bStarting Dokploy installation...%b\n" "$YELLOW" "$NC"

sudo apt-get update
sudo apt-get install -y curl ufw

sudo ufw allow 80/tcp || true
sudo ufw allow 443/tcp || true
sudo ufw allow 3000/tcp || true
sudo ufw allow 2377/tcp || true
sudo ufw allow 7946/tcp || true
sudo ufw allow 7946/udp || true
sudo ufw allow 4789/udp || true
sudo ufw --force enable

if ! command -v docker &> /dev/null; then
    curl -sSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
fi

if ! docker info | grep -q "Swarm: active"; then
    ADVERTISE_ADDR=$(curl -s ifconfig.me)
    sudo docker swarm init --advertise-addr "$ADVERTISE_ADDR"
fi

if ! docker network ls | grep -q "dokploy-network"; then
    sudo docker network create --driver overlay --attachable dokploy-network
fi

if ! docker service ls | grep -q "dokploy"; then
    sudo mkdir -p /etc/dokploy
    sudo chmod 777 /etc/dokploy
    sudo docker service create --name dokploy --replicas 1 --network dokploy-network --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock --mount type=bind,source=/etc/dokploy,target=/etc/dokploy --publish published=3000,target=3000,mode=host --update-parallelism 1 --update-order stop-first dokploy/dokploy:latest
fi

printf "%bInstallation complete!%b\n" "$GREEN" "$NC"
printf "Access Dokploy at http://%s:3000\n" "$(curl -s ifconfig.me)"
