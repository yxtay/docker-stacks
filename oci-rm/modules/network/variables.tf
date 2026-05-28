variable "compartment_ocid" {
  type        = string
  description = "OCI compartment OCID"
}

variable "vcn_display_name" {
  type        = string
  description = "VCN display name"
}

variable "vcn_cidr_block" {
  type        = string
  description = "VCN CIDR block"
}

variable "subnet_cidr_block" {
  type        = string
  description = "Subnet CIDR block"
}

variable "ssh_source_cidr" {
  type        = string
  description = "CIDR block allowed to reach port 22"
}

variable "tcp_ingress_ports" {
  type        = list(number)
  description = "List of TCP ports to allow ingress"
  default     = [80, 443, 3000]
}

variable "udp_ingress_ports" {
  type        = list(number)
  description = "List of UDP ports to allow ingress"
  default     = [443]
}
