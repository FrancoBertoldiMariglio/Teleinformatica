resource "openstack_compute_instance_v2" "lb_vm" {
  name              = "lb_vm"
  image_id          = data.openstack_images_image_v2.srv_nginx_ubuntu1804.id
  flavor_id         = data.openstack_compute_flavor_v2.small.id
  key_pair          = var.key_name
  security_groups   = [openstack_compute_secgroup_v2.sg_base.name, openstack_compute_secgroup_v2.sg_lb.name]
  availability_zone = "nodos-amd-2022"

  user_data = templatefile("templates/lb_vm_script.init.sh", {
    app_ip = openstack_compute_instance_v2.app_vm.network.0.fixed_ip_v4
  })

  network {
    name = openstack_networking_network_v2.metabase_net.name
  }

  depends_on = [
    openstack_networking_subnet_v2.metabase_subnet,
  ]
}

resource "openstack_compute_floatingip_associate_v2" "lb_vm_fip" {
  floating_ip = openstack_networking_floatingip_v2.lb_fip.address
  instance_id = openstack_compute_instance_v2.lb_vm.id
}
