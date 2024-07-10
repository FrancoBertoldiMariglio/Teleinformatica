resource "openstack_compute_secgroup_v2" "sg_base" {
  name        = "sg_base"
  description = "Security Group base para todas las VMs"

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}


resource "openstack_compute_secgroup_v2" "sg_bastion" {
  name        = "sg_bastion"
  description = "Security Group para VM bastion"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "::/0"
  }
}

resource "openstack_compute_secgroup_v2" "sg_lb" {
  name        = "sg_lb"
  description = "Security Group para VM load balancer"

  rule {
    from_group_id = openstack_compute_secgroup_v2.sg_bastion.id
    from_port     = 22
    to_port       = 22
    ip_protocol   = "tcp"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "sg_app" {
  name        = "sg_app"
  description = "sg_app"

  rule {
    from_group_id = openstack_compute_secgroup_v2.sg_bastion.id
    from_port     = 22
    to_port       = 22
    ip_protocol   = "tcp"
  }

  rule {
    from_group_id = openstack_compute_secgroup_v2.sg_lb.id
    from_port     = 3000
    to_port       = 3000
    ip_protocol   = "tcp"
  }
}

resource "openstack_compute_secgroup_v2" "sg_db" {
  name        = "sg_db"
  description = "Security Group para VM db"

  rule {
    from_group_id = openstack_compute_secgroup_v2.sg_bastion.id
    from_port     = 22
    to_port       = 22
    ip_protocol   = "tcp"
  }

   rule {
    from_port     = 3306
    to_port       = 3306
    ip_protocol   = "tcp"
    cidr          = "0.0.0.0/0"
  }
}
