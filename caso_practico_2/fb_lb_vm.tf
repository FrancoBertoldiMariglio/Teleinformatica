resource "openstack_compute_instance_v2" "tf_fb_lb" {
  name              = "tf_fb_lb"
  image_id          = data.openstack_images_image_v2.srv_nginx_ubuntu1804.id
  flavor_id         = data.openstack_compute_flavor_v2.small.id
  key_pair          = var.key_name
  security_groups   = [openstack_compute_secgroup_v2.tf_fb_sg_lb.name, openstack_compute_secgroup_v2.tf_fb_sg_base.name]
  availability_zone = "nodos-amd-2022"

  user_data = templatefile("templates/fb_lb_vm.init.sh", {
    app_ip = openstack_compute_instance_v2.tf_fb_app_vm.network.0.fixed_ip_v4
  })

  network {
    name = openstack_networking_network_v2.tf_fb_net.name
  }

  depends_on = [
    openstack_networking_subnet_v2.tf_fb_subnet,
  ]
}

resource "openstack_compute_floatingip_associate_v2" "tf_fb_lb_fip" {
  floating_ip = openstack_networking_floatingip_v2.tf_fb_lb_fip.address
  instance_id = openstack_compute_instance_v2.tf_fb_lb.id
}
