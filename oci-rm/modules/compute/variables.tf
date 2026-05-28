variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID"
}

variable "compartment_ocid" {
  type        = string
  description = "OCI compartment OCID"
}

variable "availability_domain_number" {
  type        = number
  description = "Availability domain number"
}

variable "instance_display_name" {
  type        = string
  description = "Instance display name"
}

variable "instance_ocpus" {
  type        = number
  description = "Number of OCPUs"
}

variable "instance_memory_in_gbs" {
  type        = number
  description = "Memory in GB"
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Boot volume size in GB"
}

variable "instance_image_os" {
  type        = string
  description = "Operating system"
}

variable "instance_image_os_version" {
  type        = string
  description = "OS version"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
}

variable "user_data" {
  type        = string
  description = "Encoded cloud-init script"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet OCID"
}
