packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= 1.2.0"
    }
  }
}

variable "vcenter_server" {
  type    = string
  default = ""
}

variable "vcenter_user" {
  type    = string
  default = ""
}

variable "vcenter_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "datacenter" {
  type    = string
  default = ""
}

variable "cluster" {
  type    = string
  default = ""
}

variable "datastore" {
  type    = string
  default = ""
}

variable "network" {
  type    = string
  default = ""
}

variable "iso_path" {
  type    = string
  default = ""
}

variable "ssh_password" {
  type      = string
  sensitive = true
  default   = ""
}

source "vsphere-iso" "ubuntu-desktop" {
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_user
  password            = var.vcenter_password
  insecure_connection = true
  datacenter          = var.datacenter
  cluster             = var.cluster
  datastore           = var.datastore

  vm_name              = "ubuntu-2004-server-template"
  guest_os_type        = "ubuntu64Guest"
  CPUs                 = 4
  RAM                  = 8192
  firmware             = "efi"
  disk_controller_type = ["pvscsi"]
  convert_to_template  = true

  storage {
    disk_size             = 40000
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  iso_paths = [var.iso_path]

  cd_content = {
    "/meta-data" = file("./http/meta-data")
    "/user-data" = file("./http/user-data")
  }
  cd_label = "cidata"

  communicator           = "ssh"
  ssh_username           = "ubuntu"
  ssh_password           = var.ssh_password
  ssh_timeout            = "90m"
  ssh_handshake_attempts = 100000

  boot_wait = "20s"
  boot_command = [
    "c<wait2>",
    "linux /casper/vmlinuz quiet autoinstall ds=nocloud<enter><wait5>",
    "initrd /casper/initrd<enter><wait5>",
    "boot<enter>"
  ]

  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  shutdown_timeout = "15m"
}

build {
  sources = ["source.vsphere-iso.ubuntu-desktop"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y open-vm-tools openssh-server",
      "sudo systemctl enable ssh"
    ]
  }
}

