resource "ncloud_public_ip" "public_ip" {
  server_instance_no = ncloud_server.server.instance_no
}

resource "ncloud_network_interface" "network_interface" {
  count                 = var.create_access_control_group_name != null || var.access_control_group_name != null ? 1 : 0
  subnet_no             = var.subnet_no
  name                  = "${var.vm_name}-nic"
  access_control_groups = formatlist(try(data.ncloud_access_control_group.get_access_control_group[0].access_control_group_no, ncloud_access_control_group.create_access_control_group[0].access_control_group_no))
}

data "ncloud_access_control_group" "get_access_control_group" {
  count = var.access_control_group_name != null ? 1 : 0
  name  = var.access_control_group_name
}

resource "ncloud_access_control_group" "create_access_control_group" {
  count  = var.create_access_control_group_name != null ? 1 : 0
  name   = var.create_access_control_group_name
  vpc_no = data.ncloud_subnet.get_subnet.vpc_no
}

locals {
  inbound_list = var.create_access_control_group_rules != null ? [
    for data in var.create_access_control_group_rules :
    data
    if data.direction == "ingress"
  ] : []
  outbound_list = var.create_access_control_group_rules != null ? [
    for data in var.create_access_control_group_rules :
    data
    if data.direction == "egress"
  ] : []
}

resource "ncloud_access_control_group_rule" "access_control_group_rule" {
  count                   = var.create_access_control_group_rules != null && var.create_access_control_group_name != null ? 1 : 0
  access_control_group_no = ncloud_access_control_group.create_access_control_group[0].id

  dynamic "inbound" {
    for_each = local.inbound_list
    content {
      protocol   = upper(inbound.value.protocol)
      ip_block   = inbound.value.remote_ip_prefix
      port_range = inbound.value.port_range_min == inbound.value.port_range_max ? inbound.value.port_range_max : "${inbound.value.port_range_min}-${inbound.value.port_range_max}"
    }
  }

  dynamic "outbound" {
    for_each = local.outbound_list
    content {
      protocol   = upper(outbound.value.protocol)
      ip_block   = outbound.value.remote_ip_prefix
      port_range = outbound.value.port_range_min == outbound.value.port_range_max ? outbound.value.port_range_max : "${outbound.value.port_range_min}-${outbound.value.port_range_max}"
    }
  }

  outbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }
}
