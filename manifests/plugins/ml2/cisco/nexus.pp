# == Class: neutron::plugins::ml2::cisco::nexus
#
# Configure the Cisco Nexus Mech Driver for neutron ML2 plugin
# More info available here:
# http://networking-cisco.readthedocs.io
#
# === Parameters:
#
# [*nexus_config*]
# (required) Nexus switch configuration for neutron configuration file
# Example nexus config format:
#  { 'switch_hostname' => {'username' => 'admin',
#    'password' => "password",
#    'ip_address' => "172.18.117.28",
#    'nve_src_intf' => 1,
#    'physnet' => "physnet1",
#    'vpc_pool' => "1001-1025,1028",
#    'intfcfg_portchannel' => "no lacp suspend-individual;
#                              spanning-tree port type edge trunk",
#    'https_verify' => True,
#    'https_local_certificate' => '/tmp/my_local_cert.crt',
#    'servers' => {
#      'control01' => {"ports" => "portchannel:20"},
#      'control02' => {"ports" => "portchannel:10"}
#    }}}
#
# [*managed_physical_network*]
#   (required) The name of the physical_network managed via the Cisco
#   Nexus Switch.  This string value must be present in the ml2_conf.ini
#   network_vlan_ranges variable.
#
# [*switch_heartbeat_time*]
#   (optional) Time interval to check the state of the Nexus device.
#   (default) This value defaults to 30 seconds. To disable, set to 0.
#   Defaults to 30
#
# [*provider_vlan_auto_create*]
#   (optional) A flag indicating whether OpenStack networking should manage the
#   creation and removal of VLANs for provider networks on the Nexus
#   switches. If the flag is set to False then OpenStack will not create or
#   remove VLANs for provider networks, and the administrator needs to
#   manage these interfaces manually or by external orchestration.
#   Defaults to true
#
# [*provider_vlan_auto_trunk*]
#   (optional) A flag indicating whether OpenStack networking should manage
#   the adding and removing of provider VLANs from trunk ports on the Nexus
#   switches. If the flag is set to False then OpenStack will not add or
#   remove provider VLANs from trunk ports, and the administrator needs to
#   manage these operations manually or by external orchestration.
#   Defaults to true
#
# [*vxlan_global_config*]
#   (optional) A flag indicating whether OpenStack networking should manage the
#   creating and removing of the Nexus switch VXLAN global settings of 'feature
#   nv overlay', 'feature vn-segment-vlan-based', 'interface nve 1' and the NVE
#   subcommand 'source-interface loopback #'. If the flag is set to False
#   (default) then OpenStack will not add or remove these VXLAN settings, and
#   the administrator needs to manage these operations manually or by  external
#   orchestration.
#   Defaults to true
#

class neutron::plugins::ml2::cisco::nexus (
  $nexus_config,
  $managed_physical_network,
  $switch_heartbeat_time     = 30,
  $provider_vlan_auto_create = true,
  $provider_vlan_auto_trunk  = true,
  $vxlan_global_config       = true
) {

  include ::neutron::deps
  include ::neutron::plugins::ml2::cisco

  neutron_plugin_ml2 {
    'ml2_cisco/managed_physical_network'  : value => $managed_physical_network;
    'ml2_cisco/switch_heartbeat_time'     : value => $switch_heartbeat_time;
    'ml2_cisco/provider_vlan_auto_create' : value => $provider_vlan_auto_create;
    'ml2_cisco/provider_vlan_auto_trunk'  : value => $provider_vlan_auto_trunk;
    'ml2_cisco/vxlan_global_config'       : value => $vxlan_global_config;
  }

  create_resources(neutron::plugins::ml2::cisco::nexus_switch, $nexus_config)

  create_resources(neutron::plugins::ml2::cisco::nexus_creds, $nexus_config)

}
