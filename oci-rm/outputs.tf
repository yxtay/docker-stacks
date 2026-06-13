output "instance_id" {
  description = "OCID of the created instance"
  value       = oci_core_instance.instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = var.use_reserved_public_ip ? oci_core_public_ip.reserved[0].ip_address : oci_core_instance.instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.instance.private_ip
}

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.vcn.id
}

output "ssh_username" {
  description = "SSH username for the instance"
  value       = local.ssh_username
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ${local.ssh_username}@${var.use_reserved_public_ip ? oci_core_public_ip.reserved[0].ip_address : oci_core_instance.instance.public_ip}"
}
