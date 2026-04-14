terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.12"
    }
  }
}

provider "vsphere" {
  user                 = "mat@cloud-temple.lan"
  password             = var.admin_password
  vsphere_server       = "vc-vstack-017-lab.virtualstack.tn"
  allow_unverified_ssl = true
  api_timeout          = 10
}
