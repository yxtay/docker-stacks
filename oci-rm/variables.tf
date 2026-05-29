variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID"
}

variable "compartment_ocid" {
  type        = string
  description = "OCI compartment OCID"
}

variable "region" {
  type        = string
  description = "OCI region"
}

variable "availability_domain_number" {
  type        = number
  description = "Availability domain number (1, 2, or 3)"
  default     = 1

  validation {
    condition     = var.availability_domain_number >= 1 && var.availability_domain_number <= 3
    error_message = "availability_domain_number must be 1, 2, or 3."
  }
}

variable "instance_display_name" {
  type        = string
  description = "Instance display name"
  default     = "arm-free-tier"
}

variable "instance_ocpus" {
  type        = number
  description = "Number of OCPUs (max 4 total across all A1 Always Free instances)"
  default     = 4

  validation {
    condition     = var.instance_ocpus >= 1 && var.instance_ocpus <= 4
    error_message = "instance_ocpus must be between 1 and 4 (Always Free limit)."
  }
}

variable "instance_memory_in_gbs" {
  type        = number
  description = "Memory in GB (max 24 total across all A1 Always Free instances; ratio 1:1 to 1:8 OCPU:GB)"
  default     = 24

  validation {
    condition     = var.instance_memory_in_gbs >= 1 && var.instance_memory_in_gbs <= 24
    error_message = "instance_memory_in_gbs must be between 1 and 24 (Always Free limit)."
  }
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Boot volume size in GB (min 47; Always Free allows 200 GB total block storage)"
  default     = 200

  validation {
    condition     = var.boot_volume_size_in_gbs >= 47 && var.boot_volume_size_in_gbs <= 200
    error_message = "boot_volume_size_in_gbs must be between 47 and 200."
  }
}

variable "instance_image_os" {
  type        = string
  description = "Operating system"
  default     = "Canonical Ubuntu"

  validation {
    condition     = contains(["Canonical Ubuntu", "Oracle Linux"], var.instance_image_os)
    error_message = "instance_image_os must be 'Canonical Ubuntu' or 'Oracle Linux'."
  }
}

variable "instance_image_os_version" {
  type        = string
  description = "OS version (Ubuntu: 22.04, 20.04 | Oracle Linux: 9, 8)"
  default     = "24.04"

  validation {
    condition     = contains(["24.04", "22.04", "20.04", "9", "8"], var.instance_image_os_version)
    error_message = "instance_image_os_version must be one of: 24.04, 22.04, 20.04, 9, 8."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for instance access"
}

variable "ssh_source_cidr" {
  type        = string
  description = "CIDR block allowed to reach port 22. Restrict to your IP for better security (e.g. 203.0.113.0/32)."
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.ssh_source_cidr))
    error_message = "ssh_source_cidr must be a valid CIDR block."
  }
}

variable "tcp_ingress_ports" {
  type        = string
  description = "Comma-separated list of TCP ports to allow ingress"
  default     = "80,443,9443"

  validation {
    condition     = alltrue([for p in compact(split(",", replace(var.tcp_ingress_ports, " ", ""))) : can(tonumber(p)) && tonumber(p) >= 1 && tonumber(p) <= 65535])
    error_message = "tcp_ingress_ports must be a comma-separated list of valid port numbers (1-65535)."
  }
}

variable "udp_ingress_ports" {
  type        = string
  description = "Comma-separated list of UDP ports to allow ingress"
  default     = "443"

  validation {
    condition     = alltrue([for p in compact(split(",", replace(var.udp_ingress_ports, " ", ""))) : can(tonumber(p)) && tonumber(p) >= 1 && tonumber(p) <= 65535])
    error_message = "udp_ingress_ports must be a comma-separated list of valid port numbers (1-65535)."
  }
}

variable "user_data" {
  type        = string
  description = "Cloud-init configuration to run on first boot (defaults to templates/cloud-init.yaml)"
  default     = <<-EOT
#cloud-config
package_update: true
package_upgrade: true
package_reboot_if_required: true

ssh:
  permit_root_login: false
  password_authentication: false

disable_root: true

apt:
  unattended-upgrades:
    enable: true
    auto_reboot: true

packages:
  - ufw
  - curl
  - git

write_files:
  - path: /etc/sysctl.d/99-hardening.conf
    content: |
      # IP Spoofing protection
      net.ipv4.conf.all.rp_filter = 1
      net.ipv4.conf.default.rp_filter = 1
      # Ignore ICMP broadcast requests
      net.ipv4.icmp_echo_ignore_broadcasts = 1
      # Disable source packet routing
      net.ipv4.conf.all.accept_source_route = 0
      net.ipv6.conf.all.accept_source_route = 0
      net.ipv4.conf.default.accept_source_route = 0
      net.ipv6.conf.default.accept_source_route = 0
      # Ignore send redirects
      net.ipv4.conf.all.send_redirects = 0
      net.ipv4.conf.default.send_redirects = 0
      # Block SYN attacks
      net.ipv4.tcp_syncookies = 1
      net.ipv4.tcp_max_syn_backlog = 2048
      net.ipv4.tcp_synack_retries = 2
      net.ipv4.tcp_syn_retries = 5
      # Log Martians
      net.ipv4.conf.all.log_martians = 1
      net.ipv4.conf.default.log_martians = 1

runcmd:
  # Flush iptables before enabling UFW
  - [ iptables, -P, INPUT, ACCEPT ]
  - [ iptables, -P, FORWARD, ACCEPT ]
  - [ iptables, -P, OUTPUT, ACCEPT ]
  - [ iptables, -t, nat, -F ]
  - [ iptables, -t, mangle, -F ]
  - [ iptables, -F ]
  - [ iptables, -X ]
  - [ sh, -c, "netfilter-persistent save || true" ]

  # Replace iptables with UFW
  - [ ufw, default, deny, incoming ]
  - [ ufw, default, allow, outgoing ]
  - [ ufw, allow, 22/tcp ]
  - [ ufw, allow, 80/tcp ]
  - [ ufw, allow, 443/tcp ]
  - [ ufw, allow, 443/udp ]
  - [ ufw, allow, 9443/tcp ]
  - [ ufw, --force, enable ]

  # Install Docker
  - [ sh, -c, "curl -fsSL https://get.docker.com -o get-docker.sh" ]
  - [ sh, get-docker.sh ]
  - [ sh, -c, "usermod -aG docker ubuntu || true" ]
  - [ sh, -c, "usermod -aG docker opc || true" ]
  - [ rm, get-docker.sh ]
EOT
}

variable "vcn_display_name" {
  type        = string
  description = "VCN display name"
  default     = "vcn-free-tier"
}

variable "vcn_cidr_block" {
  type        = string
  description = "VCN CIDR block"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type        = string
  description = "Subnet CIDR block"
  default     = "10.0.0.0/24"
}
