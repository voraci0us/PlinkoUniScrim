terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  application_credential_id = var.credential_id
  application_credential_secret = var.credential_secret
  auth_url    = var.auth_url
  region      = var.region
}

data "openstack_networking_network_v2" "external_network" {
  name = "External Network"
}

data "openstack_images_image_v2" "windows_server_2016" {
  name        = "Windows Server 2016"
  most_recent = true
}

data "openstack_images_image_v2" "centos_7" {
  name        = "CentOS 7"
  most_recent = true
}

data "openstack_images_image_v2" "ubuntu_22" {
  name        = "Ubuntu 22.04"
  most_recent = true
}

variable "numStudents" {
  type = number
  default = 1
}

resource "openstack_compute_instance_v2" "web" {
  count = var.numStudents
  name            = "web.student${count.index}.local"
  image_id        = data.openstack_images_image_v2.ubuntu_22.id
  flavor_name       = "m1.small"
  key_pair        = "Terraform"
  security_groups = ["default"]
  user_data       = "${file("userdata_linux.conf")}"

  network {
    uuid = data.openstack_networking_network_v2.external_network.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu_22.id 
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }
}

# This uses an image snapshot prepared on OpenStack, Windows Server 2022 with MySQL and OpenSSH Server already installed
# This is necessary due to Chocolatey ratelimiting
resource "openstack_compute_instance_v2" "db" {
  count = var.numStudents
  name            = "db.student${count.index}.local" 
  #image_id        = data.openstack_images_image_v2.windows_server_2016.id
  image_id        = "f186da6d-5f4c-4511-adfc-c55e30c7956f"
  flavor_name     = "m1.medium"
  key_pair        = "Terraform"
  security_groups = ["default"]
  user_data       = "${file("userdata_windows.conf")}"

  network {
    uuid = data.openstack_networking_network_v2.external_network.id
  }

  block_device {
    uuid                  = "f186da6d-5f4c-4511-adfc-c55e30c7956f"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }
}
resource "openstack_compute_instance_v2" "scorestack" {
  name            = "SCRIM_scorestack"
  image_id	  = data.openstack_images_image_v2.ubuntu_22.id
  flavor_name     = "m1.large"
  key_pair        = "Terraform"
  security_groups = ["default"]
  user_data       = "${file("userdata_linux.conf")}"

  network {
    uuid = data.openstack_networking_network_v2.external_network.id
  }


  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu_22.id
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }
}

output "scorestackip" {
  description = "The IP address of the instance"
  value       = openstack_compute_instance_v2.scorestack.access_ip_v4
}

output "numStudents" {
    value = var.numStudents
}

output "ip_addresses" {
    value = {
      db = openstack_compute_instance_v2.db[*].network.0.fixed_ip_v4
      web = openstack_compute_instance_v2.web[*].network.0.fixed_ip_v4
    }
}

