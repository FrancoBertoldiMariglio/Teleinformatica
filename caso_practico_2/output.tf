output "bastion_fip" {
  value = openstack_networking_floatingip_v2.bastion_fip.address
}

output "lb_fip" {
  value = openstack_networking_floatingip_v2.lb_fip.address
}

output "app_ip" {
  value = openstack_compute_instance_v2.app_vm.network.0.fixed_ip_v4
}

output "db_ip" {
  value = openstack_compute_instance_v2.db_vm.network.0.fixed_ip_v4
}