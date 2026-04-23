############################
# DATACENTER
############################

data "vsphere_datacenter" "dtx1" {
  name = "DTX1"
}

############################
# CLUSTER
############################

data "vsphere_compute_cluster" "cluster" {
  name          = "Clu001-UCS02-PRD"
  datacenter_id = data.vsphere_datacenter.dtx1.id
}

############################
# DATASTORE
############################

data "vsphere_datastore" "ds" {
  name          = "ds001-lab-stw3-data1-dtx1"
  datacenter_id = data.vsphere_datacenter.dtx1.id
}

############################
# TEMPLATE VM
############################

data "vsphere_virtual_machine" "template" {
  name          = "ubuntu-2204-desktop-template"
  datacenter_id = data.vsphere_datacenter.dtx1.id
}



############################
# VDS
############################

data "vsphere_distributed_virtual_switch" "vds" {
  name          = "PRD"
  datacenter_id = data.vsphere_datacenter.dtx1.id
}
