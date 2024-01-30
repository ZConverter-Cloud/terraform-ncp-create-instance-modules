resource "ncloud_block_storage" "storage" {
  count              = length(var.additional_volumes)
  server_instance_no = ncloud_server.server.instance_no
  name               = "${var.vm_name}-${count.index}"
  disk_detail_type   = var.storage_type
  size               = var.additional_volumes[count.index] < 10 ? 10 : var.additional_volumes[count.index] > 2000 ? 2000 : var.additional_volumes[count.index]
}
