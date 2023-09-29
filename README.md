<!-- BEGIN_TF_DOCS -->
# Azure Virtual Network Gateway Terraform module

Terraform module which creates Azure Virtual Network Gateway resources on Azure.

Supported Azure services:

* [Public IP](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
* [Azure VPN Gateway](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways)
* [Site-to-site VPN](https://learn.microsoft.com/en-us/azure/vpn-gateway/design#s2smulti)
* [ExpressRoute virtual network gateways](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.70.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_local_network_gateway.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_public_ip.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_network_gateway.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connections"></a> [connections](#input\_connections) | A MAP of connections. The key is the connection name and the value are the properties.<br>  - type:                           (required) The type of connection. Valid options are IPsec (Site-to-Site), ExpressRoute (ExpressRoute), and Vnet2Vnet (VNet-to-VNet). Each connection type requires different mandatory arguments<br>  - local\_azure\_ip\_address\_enabled: (Optional) Use private local Azure IP for the connection. Defaults to 'null' (false)<br>  <ER PARAMETERS><br>  - authorization\_key:              (Optional) The authorization key associated with the Express Route Circuit<br>  - express\_route\_circuit\_id:       (Optional) The ID of the Express Route Circuit when type is 'ExpressRoute'. The Express Route Circuit can be in the same or in a different subscription<br>  - express\_route\_gateway\_bypass:   (Optional) If true, data packets will bypass ExpressRoute Gateway for data forwarding. This is only valid for ExpressRoute connections<br>  <VPN S2S PARAMETERS><br>  - local\_network\_gateway\_name:     (Optional) The name of the local network gateway when creating Site-to-Site connection (created in local\_network\_gateways variable)<br>  - connection\_mode:                (Optional) Connection mode to use. Possible values are Default, InitiatorOnly and ResponderOnly. Defaults to 'null' (Default)<br>  - shared\_key:                     (Optional) The shared IPSec key<br>  - connection\_protocol:            (Optional) The IKE protocol version to use. Possible values are IKEv1 and IKEv2, values are IKEv1 and IKEv2. Defaults to 'null' (IKEv2)<br>  - routing\_weight:                 (Optional) The routing weight. Defaults to 'null' (10)<br>  - dpd\_timeout\_seconds:            (Optional) The dead peer detection timeout of this connection in seconds. Defaults to 'null' (45)<br>  - enable\_bgp:                     (Optional) If true, BGP (Border Gateway Protocol) is enabled for this connection. Defaults to 'null' (false)<br>  - custom\_bgp\_addresses            (optional) A block as defined bellow<br>    - primary:                      (Required) single IP address in range 169.254.21.* and 169.254.22.* that is part of the azurerm\_virtual\_network\_gateway ip\_configuration (first one)<br>    - secondary:                    (Required) single IP address in range 169.254.21.* and 169.254.22.* that is part of the azurerm\_virtual\_network\_gateway ip\_configuration (second one)<br>  - ipsec\_policy                    (optional) A block as defined bellow<br>    - dh\_group:                     (Required) The DH group used in IKE phase 1 for initial SA. Valid options are DHGroup1, DHGroup14, DHGroup2, DHGroup2048, DHGroup24, ECP256, ECP384, or None. Defaults to 'null' (DHGroup2)<br>    - ike\_encryption:               (Required) The IKE encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, or GCMAES256. Defaults to 'null' (AES128)<br>    - ike\_integrity:                (Required) The IKE integrity algorithm. Valid options are GCMAES128, GCMAES256, MD5, SHA1, SHA256, or SHA384. Defaults to 'null' (SHA256)<br>    - ipsec\_encryption:             (Required) The IPSec encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, or None. Defaults to 'null' (AES256)<br>    - ipsec\_integrity:              (Required) The IPSec integrity algorithm. Valid options are GCMAES128, GCMAES192, GCMAES256, MD5, SHA1, or SHA256. Defaults to 'null' (SHA1)<br>    - pfs\_group:                    (Required) The DH group used in IKE phase 2 for new child SA. Valid options are ECP256, ECP384, PFS1, PFS14, PFS2, PFS2048, PFS24, PFSMM, or None. Defaults to 'null' (None)<br>    - sa\_datasize:                  (Optional) The IPSec SA payload size in KB. Must be at least 1024 KB. Defaults to 'null' (102400000)<br>    - sa\_lifetime:                  (Optional) The IPSec SA lifetime in seconds. Must be at least 300 seconds. Defaults to 'null' (27000)<br>  - traffic\_selector\_policy         (optional) A block as defined bellow<br>    - local\_address\_prefixes:       (Required) List of local CIDRs  <br>    - remote\_address\_prefixes:      (Required) List of remote CIDRs | <pre>map(object({<br>    type                           = string               #ExpressRoute or IPsec<br>    local_azure_ip_address_enabled = optional(bool, null) #Azure default: false<br>    #ER<br>    authorization_key            = optional(string, null)<br>    express_route_circuit_id     = optional(string, null)<br>    express_route_gateway_bypass = optional(bool, null)<br>    #VPN<br>    local_network_gateway_name = optional(string, null)<br>    connection_mode            = optional(string, null) #Azure default: Default<br>    shared_key                 = optional(string, null)<br>    connection_protocol        = optional(string, null) #Azure default: IKEv2<br>    routing_weight             = optional(number, null) #Azure default: 10<br>    dpd_timeout_seconds        = optional(number, null) #Azure default: 45<br>    enable_bgp                 = optional(bool, null)   #Azure default: false<br>    custom_bgp_addresses = optional(object({<br>      primary   = string<br>      secondary = optional(string, null)<br>    }), null)<br><br>    #If you need to customize the policy, you should provide all parameters<br>    ipsec_policy = optional(object({<br>      dh_group         = optional(string, "DHGroup2") #Azure default: DHGroup2<br>      ike_encryption   = optional(string, "AES128")   #Azure default: AES128<br>      ike_integrity    = optional(string, "SHA256")   #Azure default: SHA256<br>      ipsec_encryption = optional(string, "AES256")   #Azure default: AES256<br>      ipsec_integrity  = optional(string, "SHA1")     #Azure default: SHA1<br>      pfs_group        = optional(string, "None")     #Azure default: None<br>      sa_datasize      = optional(number, null)       #Azure default: 102400000<br>      sa_lifetime      = optional(number, null)       #Azure default: 27000<br>    }), null)<br><br>    traffic_selector_policy = optional(list(<br>      object({<br>        local_address_prefixes  = list(string)<br>        remote_address_prefixes = list(string)<br>      })<br>    ), null)<br>  }))</pre> | `{}` | no |
| <a name="input_local_network_gateways"></a> [local\_network\_gateways](#input\_local\_network\_gateways) | A MAP of local network gateways. The key is the LNG name and the value are the properties.<br>  - address\_space:          (required) The list of string CIDRs representing the address spaces the gateway exposes. If using BGP, you should put your bgp\_peering\_address here<br>  - gateway\_address:        (optional *) The gateway IP address to connect with<br>  - gateway\_fqdn:           (optional *) The gateway FQDN to connect with<br>  - bgp\_settings:           (optional) A block as defined bellow <br>    - asn:                  (Required) The BGP speaker's ASN<br>    - bgp\_peering\_address:  (required) The BGP peering address of this BGP speaker<br>    - peer\_weight:          (optional) The weight added to routes learned from this BGP speaker<br><br>  * You should provide gateway\_address or gateway\_fqdn, but not both | <pre>map(object({<br>    address_space   = list(string)<br>    gateway_address = optional(string, null)<br>    gateway_fqdn    = optional(string, null)<br>    bgp_settings = optional(object({<br>      asn                 = string<br>      bgp_peering_address = string<br>      peer_weight         = optional(number, null)<br>    }), null)<br>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The region where the VGW will be created. This parameter is required | `string` | `"northeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | Virtual Network Gateway name. This parameter is required | `string` | n/a | yes |
| <a name="input_networking"></a> [networking](#input\_networking) | Networking properties<br>  - gateway\_subnet\_id:            (required) The GatewaySubnet id<br>  - public\_ip\_prefix\_id:          (optional) The Public IP Prefix id. Defaults to 'null'<br>  - active\_active\_enabled:        (optional) If true, an active-active Virtual Network Gateway will be created. Defaults to 'false'<br>  - private\_ip\_address\_enabled:   (optional) Define if private IP should be enabled on this gateway. Defaults to 'null'<br>  - bgp\_settings:                 (optional) A block as defined bellow <br>    - asn:                        (required) The Autonomous System Number (ASN) to use as part of the BGP<br>    - peer\_weight:                (optional) The weight added to routes which have been learned through BGP peering. Valid values can be between 0 and 100<br>    - custom\_addresses\_primary:   (optional *) A list of Azure custom APIPA addresses assigned to the BGP peer of the Virtual Network Gateway. Azure supports BGP IP in the ranges 169.254.21.* and 169.254.22.*<br>    - custom\_addresses\_secondary: (optional *) A list of Azure custom APIPA addresses assigned to the BGP peer of the Virtual Network Gateway if 'active\_active\_enabled' is 'true'. Azure supports BGP IP in the ranges 169.254.21.* and 169.254.22.*<br><br>  * If you decide to use BGP custom address and active\_active VPN, you should provide both primary and secondary addresses, if using active-passive VPN you need to provide only primary addresses. | <pre>object({<br>    gateway_subnet_id          = string<br>    public_ip_prefix_id        = optional(string, null)<br>    active_active_enabled      = optional(bool, false)<br>    private_ip_address_enabled = optional(bool, null)<br>    bgp_settings = optional(object({<br>      asn                        = number<br>      peer_weight                = optional(number, null)<br>      custom_addresses_primary   = optional(list(string), null)<br>      custom_addresses_secondary = optional(list(string), null)<br>    }), null)<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the VGW will be created. This parameter is required | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU (size) of the Virtual Network Gateway. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources. | `map(string)` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of the Virtual Network Gateway, ExpressRoute or VPN. Defaults to 'Vpn' | `string` | n/a | yes |
| <a name="input_vpn_generation"></a> [vpn\_generation](#input\_vpn\_generation) | value for the Generation for the Gateway, Valid values are 'Generation1', 'Generation2'. Options differ depending on SKU. Defaults to 'null' | `string` | `null` | no |
| <a name="input_vpn_type"></a> [vpn\_type](#input\_vpn\_type) | The VPN type of the Virtual Network Gateway. Defaults to 'RouteBased' | `string` | `"RouteBased"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_network_gateway_ids"></a> [local\_network\_gateway\_ids](#output\_local\_network\_gateway\_ids) | The Local Network Gateways names and IDs |
| <a name="output_vgw_asn"></a> [vgw\_asn](#output\_vgw\_asn) | The Virtual Network Gateway Autonomos System Number |
| <a name="output_vgw_connection_ids"></a> [vgw\_connection\_ids](#output\_vgw\_connection\_ids) | The Virtual Network Gateway Connections names and IDs |
| <a name="output_vgw_id"></a> [vgw\_id](#output\_vgw\_id) | The Virtual Network Gateway ID |
| <a name="output_vgw_name"></a> [vgw\_name](#output\_vgw\_name) | The Virtual Network Gateway Name |
| <a name="output_vgw_peering_addresses"></a> [vgw\_peering\_addresses](#output\_vgw\_peering\_addresses) | The Virtual Network Gateway Primary and Secondary* peering IPs (including the custom ones) |
| <a name="output_vgw_public_address"></a> [vgw\_public\_address](#output\_vgw\_public\_address) | The Virtual Network Gateway Primary and Secondary* public IPs |

## Examples
```hcl
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
```
More examples in ./examples folder
<!-- END_TF_DOCS -->