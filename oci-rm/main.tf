terraform {
  required_version = ">= 1.3.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

locals {
  ssh_username = var.instance_image_os == "Canonical Ubuntu" ? "ubuntu" : "opc"

  # Prepare user_data using a template if provided, or fallback to raw user_data
  user_data = var.user_data != "" ? base64encode(templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
    user_data_content = var.user_data
  })) : ""
}

module "network" {
  source = "./modules/network"

  compartment_ocid  = var.compartment_ocid
  vcn_display_name  = var.vcn_display_name
  vcn_cidr_block    = var.vcn_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  ssh_source_cidr   = var.ssh_source_cidr
  tcp_ingress_ports = var.tcp_ingress_ports
  udp_ingress_ports = var.udp_ingress_ports
}

module "compute" {
  source = "./modules/compute"

  tenancy_ocid               = var.tenancy_ocid
  compartment_ocid           = var.compartment_ocid
  availability_domain_number = var.availability_domain_number
  instance_display_name      = var.instance_display_name
  instance_ocpus             = var.instance_ocpus
  instance_memory_in_gbs     = var.instance_memory_in_gbs
  boot_volume_size_in_gbs    = var.boot_volume_size_in_gbs
  instance_image_os          = var.instance_image_os
  instance_image_os_version  = var.instance_image_os_version
  ssh_public_key             = var.ssh_public_key
  subnet_id                  = module.network.subnet_id
  user_data                  = local.user_data
}
