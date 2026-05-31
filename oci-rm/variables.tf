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

variable "instance_image_os_version" {
  type        = string
  description = "Ubuntu OS version"
  default     = "24.04"

  validation {
    condition     = contains(["24.04", "22.04", "20.04"], var.instance_image_os_version)
    error_message = "instance_image_os_version must be one of: 24.04, 22.04, 20.04."
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
  default     = ""
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
