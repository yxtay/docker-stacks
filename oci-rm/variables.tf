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
}

variable "instance_display_name" {
  type        = string
  description = "Instance display name"
  default     = "arm-free-tier"
}

variable "instance_ocpus" {
  type        = number
  description = "Number of OCPUs (max 4 total across all A1 Always Free instances)"
  default     = 2
}

variable "instance_memory_in_gbs" {
  type        = number
  description = "Memory in GB (max 24 total across all A1 Always Free instances; ratio 1:1 to 1:8 OCPU:GB)"
  default     = 12
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Boot volume size in GB (min 47; Always Free allows 200 GB total block storage)"
  default     = 50
}

variable "instance_image_os" {
  type        = string
  description = "Operating system"
  default     = "Canonical Ubuntu"
}

variable "instance_image_os_version" {
  type        = string
  description = "OS version (Ubuntu: 22.04, 20.04 | Oracle Linux: 9, 8)"
  default     = "22.04"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for instance access"
}

variable "user_data" {
  type        = string
  description = "Cloud-init script to run on first boot (paste contents of scripts/init.sh to auto-install Dokploy)"
  default     = ""
}

variable "vcn_display_name" {
  type        = string
  description = "VCN display name"
  default     = "arm-vcn"
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
