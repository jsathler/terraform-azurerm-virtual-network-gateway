/* 
To-do
- P2S VPN
- NAT Rules
*/
locals {
  tags = merge(var.tags, { ManagedByTerraform = "True" })

  # This variable was created to simplify the user input parameters
  networking = merge(var.networking, var.networking.active_active_enabled ? { ip_config_names = ["ipconfig-0", "ipconfig-1"] } : { ip_config_names = ["ipconfig-0"] })
}

resource "azurerm_public_ip" "default" {
  for_each            = toset(local.networking.ip_config_names)
  name                = "${var.name}-${each.value}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = local.networking.public_ip_prefix_id
  zones               = [1, 2, 3]
  tags                = local.tags

  #This is an workarround since if Terraform tries to delete the IP before dissasociate the IP from VGW
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_virtual_network_gateway" "default" {
  name                       = "${var.name}-vgw"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = var.type
  vpn_type                   = var.vpn_type
  sku                        = var.sku
  generation                 = var.vpn_generation
  active_active              = local.networking.active_active_enabled
  enable_bgp                 = try(local.networking.bgp_settings.asn, null) != null ? true : false
  private_ip_address_enabled = local.networking.private_ip_address_enabled
  tags                       = local.tags

  #Required
  dynamic "ip_configuration" {
    for_each = local.networking.ip_config_names
    content {
      name                 = ip_configuration.value
      subnet_id            = local.networking.gateway_subnet_id
      public_ip_address_id = azurerm_public_ip.default[ip_configuration.value].id
    }
  }

  #Optional
  dynamic "bgp_settings" {
    for_each = var.type == "Vpn" ? [local.networking] : []

    content {
      asn         = try(bgp_settings.value.bgp_settings.asn, null)
      peer_weight = try(bgp_settings.value.bgp_settings.peer_weight, null)

      dynamic "peering_addresses" {
        for_each = bgp_settings.value.ip_config_names

        content {
          ip_configuration_name = peering_addresses.value
          apipa_addresses       = peering_addresses.key == 0 ? try(bgp_settings.value.bgp_settings.custom_addresses_primary, null) : try(bgp_settings.value.bgp_settings.custom_addresses_secondary, null)
        }
      }
    }
  }
}

resource "azurerm_local_network_gateway" "default" {
  for_each            = var.local_network_gateways
  name                = "${each.key}-lgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = each.value.address_space
  gateway_address     = each.value.gateway_address
  gateway_fqdn        = each.value.gateway_fqdn
  tags                = local.tags

  dynamic "bgp_settings" {
    for_each = each.value.bgp_settings != null ? [each.value.bgp_settings] : []
    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = bgp_settings.value.peer_weight
    }
  }
}

resource "azurerm_virtual_network_gateway_connection" "default" {
  for_each = var.connections
  #General
  name                       = "${each.key}-vcn"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = each.value.type
  virtual_network_gateway_id = azurerm_virtual_network_gateway.default.id

  #To-do
  #egress_nat_rule_ids             = each.value.egress_nat_rule_ids
  #ingress_nat_rule_ids            = each.value.ingress_nat_rule_ids

  #ER
  authorization_key            = each.value.authorization_key
  express_route_circuit_id     = each.value.express_route_circuit_id
  express_route_gateway_bypass = each.value.express_route_gateway_bypass

  #S2S VPN
  local_network_gateway_id       = each.value.type == "IPsec" ? azurerm_local_network_gateway.default[each.value.local_network_gateway_name].id : null
  shared_key                     = each.value.shared_key
  connection_mode                = each.value.connection_mode
  connection_protocol            = each.value.connection_protocol
  dpd_timeout_seconds            = each.value.dpd_timeout_seconds
  enable_bgp                     = each.value.enable_bgp
  local_azure_ip_address_enabled = each.value.local_azure_ip_address_enabled
  routing_weight                 = each.value.routing_weight
  tags                           = local.tags

  dynamic "custom_bgp_addresses" {
    for_each = each.value.custom_bgp_addresses != null ? [each.value.custom_bgp_addresses] : []

    content {
      primary   = try(custom_bgp_addresses.value.primary, null)
      secondary = try(custom_bgp_addresses.value.secondary, null)
    }
  }

  dynamic "ipsec_policy" {
    for_each = each.value.ipsec_policy != null ? [each.value.ipsec_policy] : []

    content {
      dh_group         = ipsec_policy.value.dh_group
      ike_encryption   = ipsec_policy.value.ike_encryption
      ike_integrity    = ipsec_policy.value.ike_integrity
      ipsec_encryption = ipsec_policy.value.ipsec_encryption
      ipsec_integrity  = ipsec_policy.value.ipsec_integrity
      pfs_group        = ipsec_policy.value.pfs_group
      sa_datasize      = ipsec_policy.value.sa_datasize
      sa_lifetime      = ipsec_policy.value.sa_lifetime
    }
  }

  dynamic "traffic_selector_policy" {
    for_each = try(each.value.traffic_selector_policy, null) == null ? [] : each.value.traffic_selector_policy

    content {
      local_address_cidrs  = traffic_selector_policy.value.local_address_prefixes
      remote_address_cidrs = traffic_selector_policy.value.remote_address_prefixes
    }
  }
}
