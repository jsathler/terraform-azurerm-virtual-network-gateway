module "vgw-vpn" {
  source              = "jsathler/virtual-network-gateway/azurerm"
  name                = "vpn-example"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  type                = "Vpn"
  sku                 = "VpnGw2AZ"
  vpn_generation      = "Generation2"

  networking = {
    public_ip_prefix_id   = azurerm_public_ip_prefix.default.id
    gateway_subnet_id     = module.hub-vnet.subnet_ids.GatewaySubnet
    active_active_enabled = true
    bgp_settings = {
      asn = 65511
    }
  }

  local_network_gateways = {
    remote1 = {
      address_space   = ["10.10.10.10/32"]
      gateway_address = "200.200.200.200"
      bgp_settings = {
        asn                 = 65514
        bgp_peering_address = "10.10.10.10"
      }
    }
  }

  connections = {
    az-to-remote1 = {
      type                       = "IPsec"
      local_network_gateway_name = "remote1"
      shared_key                 = random_password.shared_key.result
      enable_bgp                 = true
    }
  }
}
