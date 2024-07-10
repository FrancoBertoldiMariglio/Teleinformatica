output "tf_fb_bastion_fip" {
  value = openstack_networking_floatingip_v2.tf_fb_bastion_fip.address
}

output "tf_fb_lb_fip" {
  value = openstack_networking_floatingip_v2.tf_fb_lb_fip.address
}

output "app_ip" {
  value = openstack_compute_instance_v2.tf_fb_app_vm.network.0.fixed_ip_v4
}

output "db_ip" {
  value = openstack_compute_instance_v2.tf_fb_db.network.0.fixed_ip_v4
}