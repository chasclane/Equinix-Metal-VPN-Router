auth_token = "CHANGE THIS"
ssh_private_key_path = "~/.ssh/id_rsa" # <--Validate This Path
public_ips_cidr = ["CHANGE THIS"]
project_id = "CHANGE THIS"
organization_id = "CHANGE THIS"

# Device provisioning
router_hostname = "edge-gateway" # <-- Change this to whatever hostname you choose
router_size = "c3.medium.x86" # <--Validate this is the server plan you want
facility = "dc13" # <--Validate this is the datacenter you want to deploy to
router_os = "ubuntu_18_04"
billing_cycle = "hourly"
vpn_user = "vm_admin" 

private_subnets = [
  {
    "name" : "Private Net 1",
    "nat" : true,
    "vsphere_service_type" : null,
    "routable" : true,
    "cidr" : "172.16.0.0/24"
  },
]

public_subnets = [
  {
    "name" : "Public Net 1",
    "nat" : false,
    "vsphere_service_type" : "management",
    "routable" : true,
    "ip_count" : 4
  }
]