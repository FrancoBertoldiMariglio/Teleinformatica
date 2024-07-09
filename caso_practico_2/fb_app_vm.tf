resource "openstack_compute_instance_v2" "tf_fb_app_vm" {
  name              = "tf_fb_app_vm"
  image_id          = data.openstack_images_image_v2.ubuntu_2204.id
  flavor_id         = data.openstack_compute_flavor_v2.small.id
  key_pair          = var.key_name 
  security_groups   = [openstack_compute_secgroup_v2.tf_fb_sg_app.name, openstack_compute_secgroup_v2.tf_fb_sg_base.name]
  availability_zone = "nodos-amd-2022"

  user_data = templatefile("templates/fb_app_vm.init.sh", {
    db_ip = openstack_compute_instance_v2.tf_fb_db.network.0.fixed_ip_v4,
    db_user = var.db_user,
    db_name = var.db_name,
    db_pass = var.db_pass
  })

  network {
    name = openstack_networking_network_v2.tf_fb_net.name
  }

  depends_on = [
    openstack_networking_subnet_v2.tf_fb_subnet,
  ]
}
