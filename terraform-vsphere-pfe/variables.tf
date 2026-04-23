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

variable "storage_provisioning_type" {
  description = "Type de provisionning du disque: thin ou thick."
  type        = string
  default     = "thin"

  validation {
    condition     = contains(["thin", "thick"], lower(var.storage_provisioning_type))
    error_message = "storage_provisioning_type doit etre 'thin' ou 'thick'."
  }
}

variable "ip_addressing_mode" {
  description = "Mode d'adressage IP: dhcp, statique ou automatique."
  type        = string
  default     = "automatique"

  validation {
    condition     = contains(["dhcp", "statique", "automatique"], lower(var.ip_addressing_mode))
    error_message = "ip_addressing_mode doit etre 'dhcp', 'statique' ou 'automatique'."
  }
}

variable "static_ipv4_addresses" {
  description = "Liste des IPv4 utilisees en mode statique (une IP par VM)."
  type        = list(string)
  default     = []
}

variable "static_ipv4_netmask" {
  description = "Netmask IPv4 en mode statique."
  type        = number
  default     = 24
}

variable "static_ipv4_gateway" {
  description = "Passerelle IPv4 en mode statique."
  type        = string
  default     = null
}

variable "static_dns_servers" {
  description = "Serveurs DNS utilises en mode statique."
  type        = list(string)
  default     = []
}

variable "auto_ipv4_subnet_cidr" {
  description = "Sous-reseau utilise pour l'adressage automatique."
  type        = string
  default     = "10.1.10.0/24"
}

variable "auto_ipv4_start_host" {
  description = "Premier host dans le sous-reseau pour l'adressage automatique."
  type        = number
  default     = 10
}

variable "auto_ipv4_gateway" {
  description = "Passerelle IPv4 en mode automatique."
  type        = string
  default     = "10.1.10.254"
}

variable "auto_dns_servers" {
  description = "Serveurs DNS utilises en mode automatique."
  type        = list(string)
  default     = ["8.8.8.8"]
}

variable "power_on_after_creation" {
  description = "Option demandee: demarrage auto apres creation (non supporte nativement par ce provider/version)."
  type        = bool
  default     = true
}

variable "portgroup_name" {
  default = "PFE-NETWORK"
}

variable "vlan_id" {
  default = 10
}




