output "automatic_ip_assignment" {
  description = "Resultat de l'adressage en mode automatique (IP, passerelle, DNS)."
  value = local.is_auto_mode ? {
    ips = [
      for idx in range(var.vm_count) :
      cidrhost(var.auto_ipv4_subnet_cidr, var.auto_ipv4_start_host + idx)
    ]
    gateway = var.auto_ipv4_gateway
    dns     = var.auto_dns_servers
  } : null
}




