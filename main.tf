provider "packet" {
  auth_token = var.auth_token
}

# Get VLANs for all of the subnets.
resource "packet_vlan" "private_vlans" {
  count       = length(var.private_subnets)
  facility    = var.facility
  project_id  = var.project_id
  description = jsonencode(element(var.private_subnets.*.name, count.index))
}

resource "packet_vlan" "public_vlans" {
  count       = length(var.public_subnets)
  facility    = var.facility
  project_id  = var.project_id
  description = jsonencode(element(var.public_subnets.*.name, count.index))
}

# Create and setup our edge router.
data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.py")
  vars = {
    private_subnets = jsonencode(var.private_subnets)
    private_vlans   = jsonencode(packet_vlan.private_vlans.*.vxlan)
    public_subnets  = jsonencode(var.public_subnets)
    public_vlans    = jsonencode(packet_vlan.public_vlans.*.vxlan)
    public_cidrs    = jsonencode(var.public_ips_cidr)
  }
}

resource "packet_device" "router" {
  hostname         = var.router_hostname
  plan             = var.router_size
  facilities       = [var.facility]
  operating_system = var.router_os
  billing_cycle    = var.billing_cycle
  project_id       = var.project_id
  user_data        = data.template_file.user_data.rendered
}

resource "packet_device_network_type" "router" {
  device_id = packet_device.router.id
  type = "hybrid"
  depends_on = [packet_device.router]
}

resource "packet_port_vlan_attachment" "router_priv_vlan_attach" {
  count     = length(packet_vlan.private_vlans)
  device_id = packet_device.router.id
  port_name = "eth1"
  vlan_vnid = element(packet_vlan.private_vlans.*.vxlan, count.index)
  depends_on = [packet_device_network_type.router]
}

resource "packet_port_vlan_attachment" "router_pub_vlan_attach" {
  count     = length(packet_vlan.public_vlans)
  device_id = packet_device.router.id
  port_name = "eth1"
  vlan_vnid = element(packet_vlan.public_vlans.*.vxlan, count.index)
  depends_on = [packet_device_network_type.router]
}

# Setup IPSecTunnel
resource "random_string" "ipsec_psk" {
  length           = 20
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "$!?@*"
}

resource "random_string" "vpn_pass" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "$!?@*"
}

data "template_file" "vpn_installer" {
  template = file("${path.module}/templates/l2tp_vpn.sh")
  vars = {
    ipsec_psk = random_string.ipsec_psk.result
    vpn_user  = var.vpn_user
    vpn_pass  = random_string.vpn_pass.result
  }
}

resource "null_resource" "install_vpn_server" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = packet_device.router.access_public_ipv4
  }

  provisioner "file" {
    content     = data.template_file.vpn_installer.rendered
    destination = "/root/vpn_installer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root",
      "chmod +x /root/vpn_installer.sh",
      "/root/vpn_installer.sh"
    ]
  }
}