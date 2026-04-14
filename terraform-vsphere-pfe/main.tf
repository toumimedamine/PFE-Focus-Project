resource "vsphere_virtual_machine" "vm" {

  count = var.vm_count

  name             = "${var.base_name}-${format("%02d", count.index + 1)}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

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
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.base_name}-${format("%02d", count.index + 1)}"
        domain    = "pfe.local"
      }

      network_interface {
        ipv4_address = "10.1.10.${count.index + 10}"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "10.1.10.254"
      dns_server_list = ["8.8.8.8", "1.1.1.1"]
    }
  }

  depends_on = [vsphere_distributed_port_group.pg]
}
