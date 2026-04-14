packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= 1.2.0"
    }
  }
}

source "vsphere-iso" "ubuntu-template" {
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_user
  password            = var.vcenter_password
  insecure_connection = true

  datacenter = var.datacenter
  cluster    = var.cluster
  datastore  = var.datastore

  vm_name       = "ubuntu-template"
  guest_os_type = "ubuntu64Guest"

  CPUs = 2
  RAM  = 4096

  disk_controller_type = ["pvscsi"]

  storage {
    disk_size             = 20000
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  iso_paths      = [var.iso_path]
  http_directory = "http"
  http_bind_address = "0.0.0.0"

  communicator = "ssh"
  ssh_username = "ubuntu"
  ssh_password = var.ssh_password
  ssh_timeout  = "40m"

  ip_wait_timeout            = "30m"
  ssh_handshake_attempts     = 200

  boot_wait = "5s"

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---",
    "<f10>"
  ]
}

build {
  sources = ["source.vsphere-iso.ubuntu-template"]

  provisioner "shell" {
    inline = [
      "echo '${var.ssh_password}' | sudo -S apt-get update",
      "echo '${var.ssh_password}' | sudo -S apt-get install -y open-vm-tools openssh-server",
      "echo '${var.ssh_password}' | sudo -S systemctl enable ssh",
      "echo '${var.ssh_password}' | sudo -S systemctl start ssh"
    ]
  }

  post-processor "shell-local" {
    inline = ["echo 'Template build completed successfully'"]
  }
}
