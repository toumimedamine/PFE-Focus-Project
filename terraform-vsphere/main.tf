locals {
  ip_mode         = lower(var.ip_addressing_mode)
  is_static_mode  = local.ip_mode == "statique"
  is_auto_mode    = local.ip_mode == "automatique"
  is_dhcp_mode    = local.ip_mode == "dhcp"
  use_thin_disk   = lower(var.storage_provisioning_type) == "thin"
  auto_ipv4_cidr  = split("/", var.auto_ipv4_subnet_cidr)
  auto_ipv4_base  = local.auto_ipv4_cidr[0]
  auto_ipv4_mask  = tonumber(local.auto_ipv4_cidr[1])
}

resource "vsphere_virtual_machine" "vm" {

  count = var.vm_count

  name             = "${var.base_name}-${format("%02d", count.index + 1)}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id
  folder = "DTX1/vm/PROD-CLIENT-VM"
  num_cpus = var.cpu
  memory   = var.ram

  guest_id  = data.vsphere_virtual_machine.template.guest_id
  firmware  = data.vsphere_virtual_machine.template.firmware
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = vsphere_distributed_port_group.pg.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = local.use_thin_disk
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.base_name}-${format("%02d", count.index + 1)}"
        domain    = "pfe.local"
      }

      network_interface {
        ipv4_address = local.is_dhcp_mode ? null : (
          local.is_static_mode
          ? var.static_ipv4_addresses[count.index]
          : cidrhost(var.auto_ipv4_subnet_cidr, var.auto_ipv4_start_host + count.index)
        )
        ipv4_netmask = local.is_dhcp_mode ? null : (
          local.is_static_mode
          ? var.static_ipv4_netmask
          : local.auto_ipv4_mask
        )
      }

      ipv4_gateway = local.is_dhcp_mode ? null : (
        local.is_static_mode
        ? var.static_ipv4_gateway
        : var.auto_ipv4_gateway
      )
      dns_server_list = local.is_dhcp_mode ? [] : (
        local.is_static_mode
        ? var.static_dns_servers
        : var.auto_dns_servers
      )
    }
  }

  lifecycle {
    precondition {
      condition = local.is_static_mode ? (
        length(var.static_ipv4_addresses) == var.vm_count
      ) : true
      error_message = "En mode statique, static_ipv4_addresses doit contenir une IP par VM."
    }

    precondition {
      condition = local.is_static_mode ? (
        var.static_ipv4_gateway != null && var.static_ipv4_gateway != ""
      ) : true
      error_message = "En mode statique, static_ipv4_gateway est obligatoire."
    }

    precondition {
      condition = local.is_static_mode ? (
        length(var.static_dns_servers) > 0
      ) : true
      error_message = "En mode statique, static_dns_servers doit contenir au moins un DNS."
    }
  }

  depends_on = [vsphere_distributed_port_group.pg]
}




