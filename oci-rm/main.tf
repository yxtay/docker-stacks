locals {
  ssh_username = var.instance_image_os == "Canonical Ubuntu" ? "ubuntu" : "opc"
}
