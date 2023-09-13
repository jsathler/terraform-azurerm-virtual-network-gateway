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

# resource "azurerm_express_route_circuit" "default" {
#   name                  = "nos-madrid-erc"
#   location              = azurerm_resource_group.default.location
#   resource_group_name   = azurerm_resource_group.default.name
#   service_provider_name = "NOS"
#   peering_location      = "Madrid"
#   bandwidth_in_mbps     = 50

#   sku {
#     tier   = "Standard"
#     family = "MeteredData"
#   }
# }

module "vgw-er" {
  source              = "../../"
  name                = "er-example"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  type                = "ExpressRoute"
  sku                 = "ErGw2AZ"

  networking = {
    public_ip_prefix_id = azurerm_public_ip_prefix.default.id
    gateway_subnet_id   = module.hub-vnet.subnet_ids.GatewaySubnet
  }

  # connections = {
  #   nos-madrid = {
  #     type                     = "ExpressRoute"
  #     express_route_circuit_id = azurerm_express_route_circuit.default.id
  #   }
  # }
}
