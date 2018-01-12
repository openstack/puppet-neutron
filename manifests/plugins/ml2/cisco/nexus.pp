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
#    'ssh_port' => 22,
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
# DEPRECATED
# [*vlan_name_prefix*]
#   (optional) This configuration item is OBSOLETE.
#   A short prefix to prepend to the VLAN number when creating a
#   VLAN interface. For example, if an interface is being created for
#   VLAN 2001 it will be named 'q-2001' using the default prefix.
#   The total length allowed for the prefix name and VLAN is 32 characters,
#   the prefix will be truncated if the total length is greater than 32.
#   Defaults to 'q-'
#
# [*svi_round_robin*]
#   (optional) This configuration item is OBSOLETE.
#   A flag to enable round robin scheduling of routers for SVI.
#   Defaults to false
#
# [*provider_vlan_name_prefix*]
#   (optional) This configuration item is OBSOLETE.
#   A short prefix to prepend to the VLAN number when creating a
#   provider VLAN interface. For example, if an interface is being created
#   for provider VLAN 3003 it will be named 'p-3003' using the default prefix.
#   The total length allowed for the prefix name and VLAN is 32 characters,
#   the prefix will be truncated if the total length is greater than 32.
#   Defaults to 'p-'
#
# [*persistent_switch_config*]
#   (optional) This will be deprecated.  This variable makes
#   Nexus device persistent by running the Nexus CLI 'copy run start'
#   after applying successful configurations.
#   (default) This flag defaults to False keep consistent with
#   existing functionality.
#   Defaults to false
#
# [*never_cache_ssh_connection*]
#   (optional) This will be deprecated.  This configuration prevents
#   caching ssh connections to a Nexus switch.
#   (default) This defaults to False which indicates that ssh
#   connections to Nexus switch are cached when the neutron
#   controller has fewer than 8 processes.
#   Defaults to false
#
# [*switch_replay_count*]
#   (optional) This configuration item is OBSOLETE.  The Nexus driver replay
#   behavior is to continue to attempt to connect to the down Nexus device
#   with a period equal to the heartbeat time interval. This was previously:
#   Number of times to attempt config replay with switch.
#   This variable depends on switch_heartbeat_time being enabled.
#   Defaults to $::os_service_default
#
# [*nexus_driver*]
#   (optional) This will be deprecated.  This configuration is a
#   choice of driver methods to configure Nexus devices.
#   (default) This value defaults to 'restapi' but can be configured
#   to legacy driver 'ncclient' temporarily until it is deprecated.
#   Defaults to 'restapi'
#
# [*host_key_checks*]
#   (optional) This will be deprecated.   This flag indicates whether or
#   not to enable strict host key checks when connecting to Nexus switches.
#   Defaults to false
#

class neutron::plugins::ml2::cisco::nexus (
  $nexus_config,
  $managed_physical_network,
  $vlan_name_prefix          = 'q-',
  $svi_round_robin           = false,
  $provider_vlan_name_prefix = 'p-',
  $persistent_switch_config  = false,
  $switch_heartbeat_time     = 0,
  $never_cache_ssh_connection = false,
  $switch_replay_count       = $::os_service_default,
  $nexus_driver              = 'restapi',
  $provider_vlan_auto_create = true,
  $provider_vlan_auto_trunk  = true,
  $vxlan_global_config       = true,
  $host_key_checks           = false
) {

  include ::neutron::deps
  include ::neutron::plugins::ml2::cisco

  if ! is_service_default($switch_replay_count) {
    warning('The switch_replay_count parameter is obsolete.  The Nexus driver will always attempt replay on reconnect, if enabled.')
  }
  neutron_plugin_ml2 {
    'ml2_cisco/managed_physical_network'  : value => $managed_physical_network;
    'ml2_cisco/switch_heartbeat_time'     : value => $switch_heartbeat_time;
    'ml2_cisco/provider_vlan_auto_create' : value => $provider_vlan_auto_create;
    'ml2_cisco/provider_vlan_auto_trunk'  : value => $provider_vlan_auto_trunk;
    'ml2_cisco/vxlan_global_config'       : value => $vxlan_global_config;
    #DEPRECATED ARGS
    'ml2_cisco/vlan_name_prefix'          : value => $vlan_name_prefix;
    'ml2_cisco/svi_round_robin'           : value => $svi_round_robin;
    'ml2_cisco/provider_vlan_name_prefix' : value => $provider_vlan_name_prefix;
    'ml2_cisco/persistent_switch_config'  : value => $persistent_switch_config;
    'ml2_cisco/never_cache_ssh_connection'  : value => $never_cache_ssh_connection;
    'ml2_cisco/switch_replay_count'       : value => $switch_replay_count;
    'ml2_cisco/nexus_driver'              : value => $nexus_driver;
    'ml2_cisco/host_key_checks'           : value => $host_key_checks;
  }

  create_resources(neutron::plugins::ml2::cisco::nexus_switch, $nexus_config)

  create_resources(neutron::plugins::ml2::cisco::nexus_creds, $nexus_config)

}
