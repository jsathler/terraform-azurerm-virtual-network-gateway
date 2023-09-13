locals {
  location     = "northeurope"
  local_subnet = "10.0.0.0/16"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "vgw-example-rg"
  location = local.location
}

resource "azurerm_public_ip_prefix" "default" {
  name                = "example"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  prefix_length       = 31
  zones               = [1, 2, 3]
}

module "hub-vnet" {
  source              = "jsathler/network/azurerm"
  name                = "example"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  address_space = [local.local_subnet]

  subnets = {
    GatewaySubnet = {
      address_prefixes   = [cidrsubnet(local.local_subnet, 10, 0)]
      nsg_create_default = false
    }
  }
}

resource "random_password" "shared_key" {
  length = 25
}

module "vgw-vpn" {
  source              = "../../"
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

output "vgw-vpn" {
  value = module.vgw-vpn
}
