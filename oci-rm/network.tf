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

resource "oci_core_default_route_table" "rt" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  display_name               = "${var.vcn_display_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

#checkov:skip=CKV_OCI_17:Ensure VCN inbound security lists are stateless
#checkov:skip=CKV_OCI_19:Ensure no security list allow ingress from 0.0.0.0:0 to port 22
#checkov:skip=CKV_OCI_20:Ensure no security list allow ingress from 0.0.0.0:0 to port 3389
#checkov:skip=CKV_OCI_22:Ensure no security list allow ingress from 0.0.0.0:0 to port 22
resource "oci_core_default_security_list" "sl" {
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
  display_name               = "${var.vcn_display_name}-sl"

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
    for_each = distinct(compact(split(",", replace(var.tcp_ingress_ports, " ", ""))))
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
    for_each = distinct(compact(split(",", replace(var.udp_ingress_ports, " ", ""))))
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

resource "oci_core_default_dhcp_options" "dhcp" {
  manage_default_resource_id = oci_core_vcn.vcn.default_dhcp_options_id
  display_name               = "${var.vcn_display_name}-dhcp"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }
}

resource "oci_core_subnet" "subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  cidr_block        = var.subnet_cidr_block
  display_name      = "${var.vcn_display_name}-subnet"
  route_table_id    = oci_core_default_route_table.rt.id
  security_list_ids = [oci_core_default_security_list.sl.id]
  dhcp_options_id   = oci_core_default_dhcp_options.dhcp.id
}
