variable "admin_password" {
  sensitive = true
}

variable "base_name" {
  default = "pfe-vm"
}

variable "vm_count" {
  default = 2
}

variable "cpu" {
  default = 2
}

variable "ram" {
  default = 2048
}

variable "portgroup_name" {
  default = "PFE-NETWORK"
}

variable "vlan_id" {
  default = 10
}
