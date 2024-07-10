
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  description = "bastion_fip"
  pool        = "ext_net"
}

resource "openstack_networking_floatingip_v2" "lb_fip" {
  description = "lb_fip"
  pool        = "ext_net"
}
