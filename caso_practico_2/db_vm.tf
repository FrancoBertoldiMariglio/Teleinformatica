resource "openstack_compute_instance_v2" "db_vm" {
  name              = "db_vm"
  image_id          = data.openstack_images_image_v2.srv_mysql_ubuntu1804.id
  flavor_id         = data.openstack_compute_flavor_v2.small.id
  key_pair          = var.key_name 
  security_groups   = [openstack_compute_secgroup_v2.sg_base.name, openstack_compute_secgroup_v2.sg_db.name]
  availability_zone = "nodos-amd-2022"

  user_data = templatefile("templates/db_vm_script.init.sh", {
    db_user = var.db_user,
    db_pass = var.db_pass,
    db_name = var.db_name,
  })

  network {
    name = openstack_networking_network_v2.metabase_net.name
  }

  depends_on = [
    openstack_networking_subnet_v2.metabase_subnet,
  ]
}
