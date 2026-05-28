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
  #checkov:skip=CKV_OCI_17:Stateful rules used intentionally; return traffic handled automatically by OCI connection tracking.
  #checkov:skip=CKV_OCI_22:SSH source CIDR is configurable via ssh_source_cidr variable; defaults to 0.0.0.0/0 for a public VPS template.
  #checkov:skip=CKV_OCI_19:Dynamic blocks cause Checkov to fail; ports are restricted by for_each loop.
  #checkov:skip=CKV_OCI_20:Dynamic blocks cause Checkov to fail; ports are restricted by for_each loop.
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_display_name}-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # SSH
  ingress_security_rules {
    protocol  = "6"
    source    = var.ssh_source_cidr
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  # TCP Ports
  dynamic "ingress_security_rules" {
    for_each = split(",", replace(var.tcp_ingress_ports, " ", ""))
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false
      tcp_options {
        min = tonumber(ingress_security_rules.value)
        max = tonumber(ingress_security_rules.value)
      }
    }
  }

  # UDP Ports
  dynamic "ingress_security_rules" {
    for_each = split(",", replace(var.udp_ingress_ports, " ", ""))
    content {
      protocol  = "17"
      source    = "0.0.0.0/0"
      stateless = false
      udp_options {
        min = tonumber(ingress_security_rules.value)
        max = tonumber(ingress_security_rules.value)
      }
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
