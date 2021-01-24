output "VPN_Endpoint" {
  value = packet_device.router.access_public_ipv4
}

output "VPN_PSK" {
  value = random_string.ipsec_psk.result
}

output "VPN_User" {
  value = var.vpn_user
}

output "VPN_Pasword" {
  value = random_string.vpn_pass.result
}