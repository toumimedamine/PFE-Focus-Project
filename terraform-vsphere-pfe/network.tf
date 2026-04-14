resource "vsphere_distributed_port_group" "pg" {

  name = var.portgroup_name

  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vds.id

  vlan_id = var.vlan_id

}
