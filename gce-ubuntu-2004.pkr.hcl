packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">= 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1"
    }
  }
}


variable "project_id" {
  default = "vinid-playground"
}
variable "subnetwork" {
  default = "https://www.googleapis.com/compute/v1/projects/vinid-playground/regions/asia-east2/subnetworks/gce-network"
}
variable "ssh_username" {
  default = "packer"
}
variable "source_image" {
  default = "ubuntu-2004-focal-v20201014"
}
variable "source_image_family" {
  default = "hardened-ubuntu-2004-lts"
}
variable "machine_type" {
  default = "e2-medium"
}
variable "region" {
  default = "asia-east1"
}
variable "zone" {
  default = "asia-east1-a"
}
variable "image_name" {
  default = "hardened-ubuntu-2004-lts"
}
variable "image_family" {
  default = "hardened-ubuntu-2004-lts"
}
variable "image_description" {
  default = "This image was create by packer"
}
variable "os_disk_size" {
  default = 20
}
variable "disk_type" {
  default = "pd-ssd"
}

source "googlecompute" "ubuntu-cis-image" {
  project_id          = "${var.project_id}"
  source_image        = "${var.source_image}"
  source_image_family = "${var.source_image_family}"
  subnetwork          = "${var.subnetwork}"
  ssh_username        = "${var.ssh_username}"
  region              = "${var.region}"
  zone                = "${var.zone}"
  image_description   = "${var.image_description}"
  image_name          = "${var.image_name}"
  image_family        = "${var.image_family}"
  disk_size           = "${var.os_disk_size}"
  disk_type           = "pd-ssd"
  machine_type        = "${var.machine_type}"
  use_internal_ip     = true
  omit_external_ip    = true
  preemptible         = true
  on_host_maintenance = "TERMINATE"
  tags                = ["security-chatops-access"]
  metadata = {
    "enable-oslogin" = "FALSE"
  }
}

#
source "none" {}
build {
  sources = ["source.none"]

  provisioner "ansible" {
    playbook_file = "tests/test.yml"
    extra_arguments = ["--syntax-check"]
  }

  post-processor "shell-local" {
    inline = ["echo '[defaults]\nroles_path=../' > ansible.cfg"]
  }

  communicator = "none"
}

post-processor "ansible" {
  playbook_file = "tests/test.yml"
  playbook_dir  = "./"
  extra_arguments = ["--syntax-check"]
  inventory_file = "tests/inventory"
}

post-processor "shell-local" {
  inline = ["echo '[defaults]\nroles_path=../' > ansible.cfg"]
}

post-processor "shell-local" {
  inline = ["echo '[defaults]\nroles_path=../' > ansible.cfg"]
}

variables {
  ansible_version = "3.8"
  ansible_webhook_url = "https://galaxy.ansible.com/api/v1/notifications/"
  roles_path = "../"
}

build {
  sources = ["source.googlecompute.ubuntu-cis-image"]
  provisioner "ansible" {
    user          = "packer"
    playbook_file = "./ansible/ubuntu-2004.yml"
    extra_arguments = [
      "--tags= 1.1.1"
    ]
  }
}

