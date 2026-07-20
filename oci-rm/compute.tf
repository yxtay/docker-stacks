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

resource "oci_core_instance" "instance" {
  # checkov:skip=CKV_OCI_4:Ensure OCI Compute Instance boot volume has in-transit data encryption enabled
  # checkov:skip=CKV_OCI_5:Ensure OCI Compute Instance has Legacy MetaData service endpoint disabled

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
    assign_public_ip = !var.use_reserved_public_ip
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.instance_image.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(var.user_data != "" ? var.user_data : file("${path.module}/templates/cloud-init.yaml"))
  }

  lifecycle {
    ignore_changes = [metadata["user_data"]]
  }
}

resource "oci_core_volume_backup_policy" "weekly" {
  count          = var.enable_boot_volume_backup ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.instance_display_name}-weekly-backup"

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_WEEK"
    day_of_week       = "SUNDAY"
    hour_of_day       = 3
    offset_type       = "STRUCTURED"
    retention_seconds = 2419200 # 4 weeks
    time_zone         = "UTC"
  }
}

resource "oci_core_volume_backup_policy_assignment" "boot_backup" {
  count     = var.enable_boot_volume_backup ? 1 : 0
  asset_id  = oci_core_instance.instance.boot_volume_id
  policy_id = oci_core_volume_backup_policy.weekly[0].id
}

data "oci_core_vnic_attachments" "instance_vnics" {
  count          = var.use_reserved_public_ip ? 1 : 0
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.instance.id
}

data "oci_core_private_ips" "instance_vnic_primary" {
  count   = var.use_reserved_public_ip ? 1 : 0
  vnic_id = data.oci_core_vnic_attachments.instance_vnics[0].vnic_attachments[0].vnic_id
}

resource "oci_core_public_ip" "reserved" {
  count          = var.use_reserved_public_ip ? 1 : 0
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "${var.instance_display_name}-public-ip"
  private_ip_id  = data.oci_core_private_ips.instance_vnic_primary[0].private_ips[0].id
}
