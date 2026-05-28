locals {
  ssh_username = var.instance_image_os == "Canonical Ubuntu" ? "ubuntu" : "opc"

  # Prepare user_data using a template if provided, or fallback to raw user_data
  user_data = var.user_data != "" ? base64encode(templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
    user_data_content = var.user_data
  })) : ""
}
