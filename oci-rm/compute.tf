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
}

resource "oci_core_instance" "instance" {
  #checkov:skip=CKV_OCI_5:Legacy IMDS is used intentionally for compatibility with various user scripts.
  #checkov:skip=CKV_OCI_4:PV encryption in transit is deprecated in OCI provider v6+; no supported replacement on oci_core_instance.
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
    var.user_data != "" ? { user_data = local.user_data } : {}
  )
}
