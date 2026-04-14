variable "vcenter_server" {
  type    = string
  default = "vc-vstack-017-lab.virtualstack.tn"
}

variable "vcenter_user" {
  type    = string
  default = "mat@cloud-temple.lan"
}

variable "vcenter_password" {
  type      = string
  sensitive = true
}

variable "datacenter" {
  type    = string
  default = "DTX1"
}

variable "cluster" {
  type    = string
  default = "Clu001-UCS02-PRD"
}

variable "datastore" {
  type    = string
  default = "ds001-lab-stw3-data1-dtx1"
}

variable "network" {
  type    = string
  default = "VLAN-LAB"
}

variable "iso_path" {
  type    = string
  default = "[ds001-lab-stw3-data1-dtx1] ISO/ubuntu-22.04.iso"
}

variable "ssh_password" {
  type      = string
  sensitive = true
}
