variable "auth_token" {}
variable "organization_id" {}
variable "public_ips_cidr" {}
variable "project_id" {}
variable "ssh_private_key_path" {}
variable "router_hostname" {}
variable "router_size" {}
variable "facility" {}
variable "router_os" {}
variable "billing_cycle" {}
variable "vpn_user" {}


variable "private_subnets" {
  default = [
    {
      "name" : "Private Net 1",
      "nat" : true,
      "vsphere_service_type" : null,
      "routable" : true,
      "cidr" : "172.16.0.0/24"
    },
  ]
}

variable "public_subnets" {
  default = [
    {
      "name" : "Public Net 1",
      "nat" : false,
      "vsphere_service_type" : "management",
      "routable" : true,
      "ip_count" : 4
    }
  ]
}
