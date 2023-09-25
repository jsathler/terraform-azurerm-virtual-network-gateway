variable "location" {
  description = "The region where the VGW will be created. This parameter is required"
  type        = string
  default     = "northeurope"
}

variable "name" {
  description = "Virtual Network Gateway name. This parameter is required"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the VGW will be created. This parameter is required"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources."
  type        = map(string)
  default     = null
}

variable "type" {
  description = "The type of the Virtual Network Gateway, ExpressRoute or VPN. Defaults to 'Vpn'"
  type        = string

  validation {
    condition     = contains(["ExpressRoute", "Vpn"], var.type)
    error_message = "type possible values are ExpressRoute or VPN."
  }
}

variable "sku" {
  description = "The SKU (size) of the Virtual Network Gateway."
  type        = string

  validation {
    condition     = contains(["Basic", "HighPerformance", "Standard", "UltraPerformance", "VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5", "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ", "ErGw1AZ", "ErGw2AZ", "ErGw3AZ"], var.sku)
    error_message = "sku possible values are Basic, HighPerformance, Standard, UltraPerformance, VpnGw1, VpnGw2, VpnGw3, VpnGw4, VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ, VpnGw4AZ, VpnGw5AZ, ErGw1AZ, ErGw2AZ, ErGw3AZ."
  }
}

variable "networking" {
  description = <<DESCRIPTION
  Networking properties
  - gateway_subnet_id:            (required) The GatewaySubnet id
  - public_ip_prefix_id:          (optional) The Public IP Prefix id. Defaults to 'null'
  - active_active_enabled:        (optional) If true, an active-active Virtual Network Gateway will be created. Defaults to 'false'
  - private_ip_address_enabled:   (optional) Define if private IP should be enabled on this gateway. Defaults to 'null'
  - bgp_settings:                 (optional) A block as defined bellow 
    - asn:                        (required) The Autonomous System Number (ASN) to use as part of the BGP
    - peer_weight:                (optional) The weight added to routes which have been learned through BGP peering. Valid values can be between 0 and 100
    - custom_addresses_primary:   (optional *) A list of Azure custom APIPA addresses assigned to the BGP peer of the Virtual Network Gateway. Azure supports BGP IP in the ranges 169.254.21.* and 169.254.22.*
    - custom_addresses_secondary: (optional *) A list of Azure custom APIPA addresses assigned to the BGP peer of the Virtual Network Gateway if 'active_active_enabled' is 'true'. Azure supports BGP IP in the ranges 169.254.21.* and 169.254.22.*
  
  * If you decide to use BGP custom address and active_active VPN, you should provide both primary and secondary addresses, if using active-passive VPN you need to provide only primary addresses.   
  DESCRIPTION

  type = object({
    gateway_subnet_id          = string
    public_ip_prefix_id        = optional(string, null)
    active_active_enabled      = optional(bool, false)
    private_ip_address_enabled = optional(bool, null)
    bgp_settings = optional(object({
      asn                        = number
      peer_weight                = optional(number, null)
      custom_addresses_primary   = optional(list(string), null)
      custom_addresses_secondary = optional(list(string), null)
    }), null)
  })
}

variable "vpn_type" {
  description = "The VPN type of the Virtual Network Gateway. Defaults to 'RouteBased'"
  type        = string
  default     = "RouteBased"

  validation {
    condition     = contains(["PolicyBased", "RouteBased"], var.vpn_type)
    error_message = "vpn_type possible values are PolicyBased or RouteBased. Defaults to 'RouteBased'"
  }
}

variable "vpn_generation" {
  description = "value for the Generation for the Gateway, Valid values are 'Generation1', 'Generation2'. Options differ depending on SKU. Defaults to 'null'"
  type        = string
  default     = null

  validation {
    condition     = var.vpn_generation == null ? true : contains(["Generation1", "Generation2"], var.vpn_generation)
    error_message = "vpn_generation possible values are 'null', 'Generation1', 'Generation2'. Options differ depending on SKU and defaults to 'null'"
  }
}

variable "connections" {
  description = <<DESCRIPTION
  A MAP of connections. The key is the connection name and the value are the properties.
  - type:                           (required) The type of connection. Valid options are IPsec (Site-to-Site), ExpressRoute (ExpressRoute), and Vnet2Vnet (VNet-to-VNet). Each connection type requires different mandatory arguments
  - local_azure_ip_address_enabled: (Optional) Use private local Azure IP for the connection. Defaults to 'null' (false)
  <ER PARAMETERS>
  - authorization_key:              (Optional) The authorization key associated with the Express Route Circuit
  - express_route_circuit_id:       (Optional) The ID of the Express Route Circuit when type is 'ExpressRoute'. The Express Route Circuit can be in the same or in a different subscription
  - express_route_gateway_bypass:   (Optional) If true, data packets will bypass ExpressRoute Gateway for data forwarding. This is only valid for ExpressRoute connections
  <VPN S2S PARAMETERS>
  - local_network_gateway_name:     (Optional) The name of the local network gateway when creating Site-to-Site connection (created in local_network_gateways variable)
  - connection_mode:                (Optional) Connection mode to use. Possible values are Default, InitiatorOnly and ResponderOnly. Defaults to 'null' (Default)
  - shared_key:                     (Optional) The shared IPSec key
  - connection_protocol:            (Optional) The IKE protocol version to use. Possible values are IKEv1 and IKEv2, values are IKEv1 and IKEv2. Defaults to 'null' (IKEv2)
  - routing_weight:                 (Optional) The routing weight. Defaults to 'null' (10)
  - dpd_timeout_seconds:            (Optional) The dead peer detection timeout of this connection in seconds. Defaults to 'null' (45)
  - enable_bgp:                     (Optional) If true, BGP (Border Gateway Protocol) is enabled for this connection. Defaults to 'null' (false)
  - custom_bgp_addresses            (optional) A block as defined bellow
    - primary:                      (Required) single IP address in range 169.254.21.* and 169.254.22.* that is part of the azurerm_virtual_network_gateway ip_configuration (first one)
    - secondary:                    (Required) single IP address in range 169.254.21.* and 169.254.22.* that is part of the azurerm_virtual_network_gateway ip_configuration (second one)
  - ipsec_policy                    (optional) A block as defined bellow
    - dh_group:                     (Required) The DH group used in IKE phase 1 for initial SA. Valid options are DHGroup1, DHGroup14, DHGroup2, DHGroup2048, DHGroup24, ECP256, ECP384, or None. Defaults to 'null' (DHGroup2)
    - ike_encryption:               (Required) The IKE encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, or GCMAES256. Defaults to 'null' (AES128)
    - ike_integrity:                (Required) The IKE integrity algorithm. Valid options are GCMAES128, GCMAES256, MD5, SHA1, SHA256, or SHA384. Defaults to 'null' (SHA256)
    - ipsec_encryption:             (Required) The IPSec encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, or None. Defaults to 'null' (AES256)
    - ipsec_integrity:              (Required) The IPSec integrity algorithm. Valid options are GCMAES128, GCMAES192, GCMAES256, MD5, SHA1, or SHA256. Defaults to 'null' (SHA1)
    - pfs_group:                    (Required) The DH group used in IKE phase 2 for new child SA. Valid options are ECP256, ECP384, PFS1, PFS14, PFS2, PFS2048, PFS24, PFSMM, or None. Defaults to 'null' (None)
    - sa_datasize:                  (Optional) The IPSec SA payload size in KB. Must be at least 1024 KB. Defaults to 'null' (102400000)
    - sa_lifetime:                  (Optional) The IPSec SA lifetime in seconds. Must be at least 300 seconds. Defaults to 'null' (27000)
  - traffic_selector_policy         (optional) A block as defined bellow
    - local_address_prefixes:       (Required) List of local CIDRs      
    - remote_address_prefixes:      (Required) List of remote CIDRs

  DESCRIPTION

  type = map(object({
    type                           = string               #ExpressRoute or IPsec
    local_azure_ip_address_enabled = optional(bool, null) #Azure default: false
    #ER
    authorization_key            = optional(string, null)
    express_route_circuit_id     = optional(string, null)
    express_route_gateway_bypass = optional(bool, null)
    #VPN
    local_network_gateway_name = optional(string, null)
    connection_mode            = optional(string, null) #Azure default: Default
    shared_key                 = optional(string, null)
    connection_protocol        = optional(string, null) #Azure default: IKEv2
    routing_weight             = optional(number, null) #Azure default: 10
    dpd_timeout_seconds        = optional(number, null) #Azure default: 45
    enable_bgp                 = optional(bool, null)   #Azure default: false
    custom_bgp_addresses = optional(object({
      primary   = string
      secondary = optional(string, null)
    }), null)

    #If you need to customize the policy, you should provide all parameters
    ipsec_policy = optional(object({
      dh_group         = optional(string, "DHGroup2") #Azure default: DHGroup2
      ike_encryption   = optional(string, "AES128")   #Azure default: AES128
      ike_integrity    = optional(string, "SHA256")   #Azure default: SHA256
      ipsec_encryption = optional(string, "AES256")   #Azure default: AES256
      ipsec_integrity  = optional(string, "SHA1")     #Azure default: SHA1
      pfs_group        = optional(string, "None")     #Azure default: None
      sa_datasize      = optional(number, null)       #Azure default: 102400000
      sa_lifetime      = optional(number, null)       #Azure default: 27000
    }), null)

    traffic_selector_policy = optional(list(
      object({
        local_address_prefixes  = list(string)
        remote_address_prefixes = list(string)
      })
    ), null)
  }))

  default = {}
}

variable "local_network_gateways" {
  description = <<DESCRIPTION
  A MAP of local network gateways. The key is the LNG name and the value are the properties.
  - address_space:          (required) The list of string CIDRs representing the address spaces the gateway exposes. If using BGP, you should put your bgp_peering_address here
  - gateway_address:        (optional *) The gateway IP address to connect with
  - gateway_fqdn:           (optional *) The gateway FQDN to connect with
  - bgp_settings:           (optional) A block as defined bellow 
    - asn:                  (Required) The BGP speaker's ASN
    - bgp_peering_address:  (required) The BGP peering address of this BGP speaker
    - peer_weight:          (optional) The weight added to routes learned from this BGP speaker

  * You should provide gateway_address or gateway_fqdn, but not both
  DESCRIPTION

  type = map(object({
    address_space   = list(string)
    gateway_address = optional(string, null)
    gateway_fqdn    = optional(string, null)
    bgp_settings = optional(object({
      asn                 = string
      bgp_peering_address = string
      peer_weight         = optional(number, null)
    }), null)
  }))

  default = {}
}
