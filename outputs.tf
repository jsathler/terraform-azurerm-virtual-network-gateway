output "vgw_name" {
  description = "The Virtual Network Gateway Name"
  value       = azurerm_virtual_network_gateway.default.name
}

output "vgw_id" {
  description = "The Virtual Network Gateway ID"
  value       = azurerm_virtual_network_gateway.default.id
}

output "vgw_asn" {
  description = "The Virtual Network Gateway Autonomos System Number"
  value       = azurerm_virtual_network_gateway.default.bgp_settings[0].asn
}

output "vgw_public_address" {
  description = "The Virtual Network Gateway Primary and Secondary* public IPs"
  value       = [for peering_address in azurerm_virtual_network_gateway.default.bgp_settings[0].peering_addresses : peering_address.tunnel_ip_addresses]
}

output "vgw_peering_addresses" {
  description = "The Virtual Network Gateway Primary and Secondary* peering IPs (including the custom ones)"
  value       = [flatten(concat([for peering_address in azurerm_virtual_network_gateway.default.bgp_settings[0].peering_addresses : peering_address.default_addresses], [for peering_address in azurerm_virtual_network_gateway.default.bgp_settings[0].peering_addresses : peering_address.apipa_addresses]))]
}

output "vgw_connection_ids" {
  description = "The Virtual Network Gateway Connections names and IDs"
  value       = { for key, value in azurerm_virtual_network_gateway_connection.default : value.name => value.id }
}

output "local_network_gateway_ids" {
  description = "The Local Network Gateways names and IDs"
  value       = { for key, value in azurerm_local_network_gateway.default : value.name => value.id }
}
