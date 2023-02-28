resource "ncloud_init_script" "init" {
  count = fileexists(var.user_data_file_path) != false && var.user_data_file_path != null ? 1 : 0
  content = replace(file(var.user_data_file_path), "/[^[:alnum:][:space:][:punct:]]+/", "")#file(var.user_data_file_path)
}

resource "ncloud_server" "server" {
  name                      = var.vm_name
  subnet_no                 = var.subnet_no
  server_image_product_code = local.server_image[0].id
  server_product_code       = data.ncloud_server_products.product.server_products[0].id

  dynamic "network_interface" {
    for_each = var.create_access_control_group_name != null || var.access_control_group_name != null ? [1] : []
    content {
      network_interface_no = ncloud_network_interface.network_interface[0].id
      order                = 0
    }
  }

  login_key_name = var.login_key_name
  init_script_no = fileexists(var.user_data_file_path) != false && var.user_data_file_path != null ? ncloud_init_script.init[0].id : null
}
