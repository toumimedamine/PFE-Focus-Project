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

  datacenter = var.datacenter
  cluster    = var.cluster
  datastore  = var.datastore

  vm_name              = "ubuntu-2204-desktop-template"
  guest_os_type        = "ubuntu64Guest"
  CPUs                 = 8
  RAM                  = 12288
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
  ip_wait_timeout        = "60m"
  ip_settle_timeout      = "30s"

  # Méthode stable dans ton environnement
  boot_wait = "5s"
  boot_command = [
    "<wait170>",
    "yes<enter>",
    "<wait2>",
    "yes<enter>"
  ]

  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  shutdown_timeout = "30m"
}

build {
  sources = ["source.vsphere-iso.ubuntu-desktop"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{.Path}}'"
    inline = [
      "apt-get update -y",
      "apt-get install -y open-vm-tools-desktop openssh-server",
      "systemctl enable ssh",
      "if [ -f /etc/ssh/sshd_config.d/60-cloudimg-settings.conf ]; then sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf; else sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config; fi",
      "systemctl restart ssh || true"
    ]
  }
}

