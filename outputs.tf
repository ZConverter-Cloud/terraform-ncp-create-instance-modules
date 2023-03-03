output "result" {
  value = {
    IP = ncloud_public_ip.public_ip.public_ip,
    OS = "${var.OS}-${var.OS_version}",
    VM_NAME = var.vm_name
  }
}
