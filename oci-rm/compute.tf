data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

data "oci_core_images" "instance_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = var.instance_image_os_version
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  lifecycle {
    postcondition {
      condition     = length(self.images) > 0
      error_message = "No images found for Canonical Ubuntu ${var.instance_image_os_version} with shape VM.Standard.A1.Flex in this region/compartment."
    }
  }
}

#checkov:skip=CKV_OCI_2:KMS not available in Always Free tier
#checkov:skip=CKV_OCI_15:Backup policy not required for ephemeral dev instance
resource "oci_core_boot_volume" "boot_volume" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.instance_display_name}-boot-volume"
  size_in_gbs         = var.boot_volume_size_in_gbs

  source_details {
    id   = data.oci_core_images.instance_image.images[0].id
    type = "image"
  }

  # To change OS version: taint this resource then apply
  lifecycle {
    ignore_changes = [source_details]
  }
}

#checkov:skip=CKV_OCI_4:Ensure OCI Compute Instance boot volume has in-transit data encryption enabled
#checkov:skip=CKV_OCI_5:Ensure OCI Compute Instance has Legacy MetaData service endpoint disabled
resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = "VM.Standard.A1.Flex"

  preserve_boot_volume = true

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
    source_type = "bootVolume"
    source_id   = oci_core_boot_volume.boot_volume.id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(var.user_data != "" ? var.user_data : file("${path.module}/templates/cloud-init.yaml"))
  }
}
