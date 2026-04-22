vcenter_server   = "vc-vstack-017-lab.virtualstack.tn"
vcenter_user     = "mat@cloud-temple.lan"
vcenter_password = "RR3f#3$3j4?Niy"

datacenter = "DTX1"
cluster    = "Clu001-UCS02-PRD"
datastore  = "ds001-lab-stw3-data1-dtx1"
vm_folder  = "Templates"
network    = "VLAN-LAB"

iso_path = "[ds001-lab-stw3-data1-dtx1] ISO/windows-server2025.iso"

template_name = "win2025-template"

cpu    = 4
ram_mb = 8192
disk_mb = 60000

winrm_password = "Admin123!"
winrm_host     = "10.1.10.6"



