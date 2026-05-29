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
  # checkov:skip=CKV_OCI_17:Stateful rules used intentionally; return traffic handled automatically.
  # checkov:skip=CKV_OCI_19:SSH port is open for initial access to the VPS.
  # checkov:skip=CKV_OCI_22:SSH source CIDR is configurable via variable.
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

  # HTTP
  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS (TCP)
  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  # HTTPS (UDP)
  ingress_security_rules {
    protocol  = "17"
    source    = "0.0.0.0/0"
    stateless = false
    udp_options {
      min = 443
      max = 443
    }
  }

  # Dokploy Dashboard
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
