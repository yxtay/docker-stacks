output "instance_id" {
  description = "OCID of the created instance"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = module.compute.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = module.compute.private_ip
}

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = module.network.vcn_id
}

output "ssh_username" {
  description = "SSH username for the instance"
  value       = local.ssh_username
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ${local.ssh_username}@${module.compute.public_ip}"
}
