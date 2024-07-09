output "tf_fb_bastion_fip" {
  value = openstack_networking_floatingip_v2.tf_fb_bastion_fip.address
}

output "tf_fb_lb_fip" {
  value = openstack_networking_floatingip_v2.tf_fb_lb_fip.address
}
