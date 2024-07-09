resource "openstack_compute_instance_v2" "tf_fb_db" {
  name              = "tf_fb_db"
  image_id          = data.openstack_images_image_v2.srv_mysql_ubuntu1804.id
  flavor_id         = data.openstack_compute_flavor_v2.small.id
  key_pair          = var.key_name 
  security_groups   = [openstack_compute_secgroup_v2.tf_fb_sg_db.name, openstack_compute_secgroup_v2.tf_fb_sg_base.name]
  availability_zone = "nodos-amd-2022"

  user_data = templatefile("templates/fb_db_vm.init.sh", {
    db_user = var.db_user,
    db_pass = var.db_pass,
    db_name = var.db_name,
  })

  network {
    name = openstack_networking_network_v2.tf_fb_net.name
  }

  provisioner "file" {
    source      = "google-mobility.sql.gz"
    destination = "/tmp/google-mobility.sql.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "gzip -d /tmp/google-mobility.sql.gz",
      "sudo mysql ${var.db_name} < /tmp/google-mobility.sql",
      "rm /tmp/google-mobility.sql.gz /tmp/google-mobility.sql"
    ]
  }

  depends_on = [
    openstack_networking_subnet_v2.tf_fb_subnet,
  ]
}
