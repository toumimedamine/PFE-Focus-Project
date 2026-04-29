packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= 2.1.2"
    }
  }
}

# ================= LOCALS DEPUIS VAULT =================
locals {
  vcenter_server    = vault("kv-v2/data/packer/windows-2025", "vcenter_server")
  vcenter_user      = vault("kv-v2/data/packer/windows-2025", "vcenter_user")
  vcenter_password  = vault("kv-v2/data/packer/windows-2025", "vcenter_password")
  winadmin_password = vault("kv-v2/data/packer/windows-2025", "winadmin_password")
  iso_path          = vault("kv-v2/data/packer/windows-2025", "iso_path")
  template_name     = vault("kv-v2/data/packer/windows-2025", "template_name")
  datacenter        = vault("kv-v2/data/packer/windows-2025", "datacenter")
  cluster           = vault("kv-v2/data/packer/windows-2025", "cluster")
  datastore         = vault("kv-v2/data/packer/windows-2025", "datastore")
  network           = vault("kv-v2/data/packer/windows-2025", "network")
}

# ================= VARIABLES (ressources uniquement) =================
variable "cpu" {
  type    = number
  default = 4
}
variable "ram_mb" {
  type    = number
  default = 8192
}
variable "disk_mb" {
  type    = number
  default = 60000
}

# ================= SOURCE =================
source "vsphere-iso" "windows-server2025" {

  vcenter_server      = local.vcenter_server
  username            = local.vcenter_user
  password            = local.vcenter_password
  insecure_connection = true

  datacenter = local.datacenter
  cluster    = local.cluster
  datastore  = local.datastore

  vm_name             = local.template_name
  guest_os_type       = "windows9Server64Guest"
  CPUs                = var.cpu
  RAM                 = var.ram_mb
  firmware            = "bios"
  convert_to_template = true

  storage {
    disk_size             = var.disk_mb
    disk_thin_provisioned = true
  }

  disk_controller_type = ["pvscsi"]

  network_adapters {
    network      = local.network
    network_card = "vmxnet3"
  }

  iso_paths = [
    local.iso_path,
    "[ds001-lab-stw3-data1-dtx1] ISO/windows.iso"
  ]

  cd_files = ["http/autounattend.xml"]
  cd_label = "PACKER"

  boot_wait = "5s"
  boot_command = [
    "<wait5>",
    "<spacebar>",
    "<wait1200>"
  ]

  ip_wait_timeout   = "2h"
  ip_settle_timeout = "30s"

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = local.winadmin_password
  winrm_timeout  = "4h"
  winrm_insecure = true

  shutdown_command = "shutdown /s /t 10"
}

# ================= BUILD =================
build {
  sources = ["source.vsphere-iso.windows-server2025"]

  provisioner "powershell" {
    inline = [
      "$ip='10.1.10.6'",
      "$prefix=24",
      "$gw='10.1.10.254'",
      "$dns=@('8.8.8.8')",
      "$a = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1",
      "New-NetIPAddress -InterfaceAlias $a.Name -IPAddress $ip -PrefixLength $prefix -DefaultGateway $gw -ErrorAction SilentlyContinue",
      "Set-DnsClientServerAddress -InterfaceAlias $a.Name -ServerAddresses $dns"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }
}
