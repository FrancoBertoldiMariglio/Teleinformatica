resource "openstack_networking_router_v2" "tf_fb_router" {
  name                = "tf_fb_router"
  admin_state_up      = "true"
  external_network_id = data.openstack_networking_network_v2.ext_net.id
}

resource "openstack_networking_network_v2" "tf_fb_net" {
  name           = "tf_fb_net"
  admin_state_up = "true"
  shared         = "false"
}

resource "openstack_networking_subnet_v2" "tf_fb_subnet" {
  name            = "tf_fb_subnet"
  network_id      = openstack_networking_network_v2.tf_fb_net.id
  cidr            = "172.19.0.0/24"
  ip_version      = 4
  enable_dhcp     = "true"
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

resource "openstack_networking_router_interface_v2" "tf_router_iface_internal" {
  router_id = openstack_networking_router_v2.tf_fb_router.id
  subnet_id = openstack_networking_subnet_v2.tf_fb_subnet.id
}
