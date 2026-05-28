terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}

provider "oci" {
  # Credentials auto-injected by Resource Manager.
  # For local use, configure ~/.oci/config or set OCI_* env vars.
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

locals {
  ssh_username = var.instance_image_os == "Canonical Ubuntu" ? "ubuntu" : "opc"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

data "oci_core_images" "instance_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_image_os
  operating_system_version = var.instance_image_os_version
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  lifecycle {
    postcondition {
      condition     = length(self.images) > 0
      error_message = "No images found for ${var.instance_image_os} ${var.instance_image_os_version} with shape VM.Standard.A1.Flex in this region/compartment."
    }
  }
}

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = var.vcn_display_name
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-igw"
  enabled        = true
}

resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_security_list" "sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol  = "17"
    source    = "0.0.0.0/0"
    stateless = false
    udp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 3000
      max = 3000
    }
  }

  # ICMP type 3 code 4: fragmentation needed (required for path MTU discovery)
  ingress_security_rules {
    protocol  = "1"
    source    = "0.0.0.0/0"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_subnet" "subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  cidr_block        = var.subnet_cidr_block
  display_name      = "${var.vcn_display_name}-subnet"
  route_table_id    = oci_core_route_table.rt.id
  security_list_ids = [oci_core_security_list.sl.id]
}

resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "${var.instance_display_name}-vnic"
    assign_public_ip = true
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.instance_image.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = merge(
    { ssh_authorized_keys = var.ssh_public_key },
    var.user_data != "" ? { user_data = base64encode(var.user_data) } : {}
  )
}
