packer {
  required_plugins {
	vsphere = {
  	source  = "github.com/hashicorp/vsphere"
  	version = ">= 1.2.0"
	}
  }
}
variable "vcenter_server" {
  type = string
}

variable "vcenter_user" {
  type = string
}

variable "vcenter_password" {
  type  	= string
  sensitive = true
}

variable "datacenter" {
  type = string
}

variable "cluster" {
  type = string
}

variable "datastore" {
  type = string
}

variable "network" {
  type = string
}

variable "iso_path" {
  type = string
}

variable "template_name" {
  type = string
}

variable "cpu" {
  type	= number
  default = 4
}

variable "ram_mb" {
  type	= number
  default = 8192
}

variable "disk_mb" {
  type	= number
  default = 60000
}

variable "winrm_password" {
  type  	= string
  sensitive = true
}

variable "winrm_host" {
  type = string
}
variable "vm_folder" {
 type = string
}

source "vsphere-iso" "windows-server2025" {
  # ── vCenter connection ──────────────────────────────────────────────────────
  vcenter_server  	= var.vcenter_server
  username        	= var.vcenter_user
  password        	= var.vcenter_password
  insecure_connection = true

  # ── Infrastructure placement ────────────────────────────────────────────────
  datacenter = var.datacenter
  cluster	= var.cluster
  datastore  = var.datastore
  folder 	= var.vm_folder

  # ── VM identity ─────────────────────────────────────────────────────────────
  vm_name         	= var.template_name
  guest_os_type   	= "windows9Server64Guest"
  firmware        	= "bios"
  convert_to_template = true

  # ── ISO + CD autounattend ────────────────────────────────────────────────────
  iso_paths = [var.iso_path]

  cd_content = {
	"autounattend.xml" = file("http/autounattend.xml")
  }
  cd_label = "AUTOUNATTEND"

  # ── Hardware ─────────────────────────────────────────────────────────────────
  CPUs             	= var.cpu
  RAM              	= var.ram_mb
  disk_controller_type = ["pvscsi"]

  storage {
	disk_size         	= var.disk_mb
	disk_thin_provisioned = true
  }

  network_adapters {
	network  	= var.network
	network_card = "vmxnet3"
  }

  # ── Boot ─────────────────────────────────────────────────────────────────────
  # <wait600> = 10 min : réduit le temps d'attente fixe
  # → évite les 502/504 pendant l'installation Windows
  boot_wait = "5s"
  boot_command = [
	"<wait5>",
	"<spacebar>",
	"<wait1200>",
  ]

  # ── WinRM ────────────────────────────────────────────────────────────────────
  communicator   = "winrm"
  winrm_host 	= var.winrm_host
  winrm_username = "Administrator"
  winrm_password = var.winrm_password
  winrm_timeout  = "2h"
  winrm_use_ssl  = false
  winrm_insecure = true
  winrm_port 	= 5985
  winrm_use_ntlm = false

  # ── Timeouts ─────────────────────────────────────────────────────────────────
  # Bypass vCenter IP polling (fragile ici avec erreurs 502/504 sur /sdk).
  # On se connecte directement via winrm_host statique.
  ip_wait_timeout     	= "0s"
  ip_settle_timeout   	= "0s"
  pause_before_connecting = "5m"
  shutdown_timeout    	= "30m"

  shutdown_command = "powershell -Command \"Stop-Computer -Force\""
}

# ── Build ─────────────────────────────────────────────────────────────────────
build {
  sources = ["vsphere-iso.windows-server2025"]

  # 1. Vérification finale
  provisioner "powershell" {
	inline = [
  	"Write-Host '=== VM ready for template ==='",
  	"ipconfig",
  	"Get-Service -Name 'VMTools' -ErrorAction SilentlyContinue | Select-Object Name, Status",
	]
  }
}








