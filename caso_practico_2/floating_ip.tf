
resource "openstack_networking_floatingip_v2" "tf_fb_bastion_fip" {
  description = "tf_fb_bastion_fip"
  pool        = "ext_net"
}

resource "openstack_networking_floatingip_v2" "tf_fb_lb_fip" {
  description = "tf_fb_lb_fip"
  pool        = "ext_net"
}
