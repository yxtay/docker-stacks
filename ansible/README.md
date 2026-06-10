# Ansible Provisioning

Provisions and hardens Docker hosts across Proxmox LXC and OCI VPS targets.

## Community Roles

- `robertdebock.bootstrap` — install Python, sudo, and basic packages for Ansible
- `robertdebock.update` — dist-upgrade + reboot-if-needed
- `lae.proxmox` — Proxmox post-install (no-sub repo, disable enterprise)
- `geerlingguy.security` — SSH hardening, fail2ban, unattended-upgrades
- `geerlingguy.docker` — Docker CE + Compose plugin

## Custom Roles

- `bootstrap` — timezone, default user, SSH key for user
- `lxc` — create Proxmox LXC container (unprivileged, nesting, ID mapping,
  root SSH key)
- `oci_firewall` — iptables rules (insert, preserves OCI defaults)

## Prerequisites

```bash
pip install ansible
ansible-galaxy install -r requirements.yml
```

## Configure

Copy example host vars and fill in IPs:

```bash
cp host_vars/pve.yml.example host_vars/pve.yml
cp host_vars/oci-vps.yml.example host_vars/oci-vps.yml
```

Adjust group vars:

- `group_vars/all/main.yml` — shared settings
- `group_vars/lxc/main.yml` — LXC specs (cores, memory, disk)
- `group_vars/oci/main.yml` — firewall ports

## Run

```bash
# Configure Proxmox host (post-install)
ansible-playbook playbook-proxmox.yml -e ansible_user=root

# Provision Proxmox LXC + Docker
ansible-playbook playbook-lxc.yml

# Provision OCI VPS (replaces cloud-init)
ansible-playbook playbook-oci.yml

# Dist-upgrade specific hosts
ansible-playbook upgrade.yml -e hosts=proxmox,lxc,oci
```
