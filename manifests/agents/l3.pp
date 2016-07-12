# == Class: neutron::agents::l3
#
# Installs and configures the Neutron L3 service
#
# TODO: create ability to have multiple L3 services
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   (optional) Print debug info in logs
#   Defaults to false
#
# [*interface_driver*]
#   (optional) Driver to interface with neutron
#   Defaults to OVSInterfaceDriver
#
# [*gateway_external_network_id*]
#   (optional) The ID of the external network in neutron
#   Defaults to $::os_service_default
#
# [*handle_internal_only_routers*]
#   (optional) L3 Agent will handle non-external routers
#   Defaults to $::os_service_default
#
# [*metadata_port*]
#   (optional) The port of the metadata server
#   Defaults to $::os_service_default
#
# [*send_arp_for_ha*]
#   (optional) Send this many gratuitous ARPs for HA setup. Set it below or equal to 0
#   to disable this feature.
#   Defaults to $::os_service_default
#
# [*periodic_interval*]
#   (optional) seconds between re-sync routers' data if needed
#   Defaults to $::os_service_default
#
# [*periodic_fuzzy_delay*]
#   (optional) seconds to start to sync routers' data after starting agent
#   Defaults to $::os_service_default
#
# [*enable_metadata_proxy*]
#   (optional) can be set to False if the Nova metadata server is not available
#   Defaults to $::os_service_default
#
# [*ha_enabled*]
#   (optional) Enabled or not HA for L3 agent.
#   Defaults to false
#
# [*ha_vrrp_auth_type*]
#   (optional) VRRP authentication type. Can be AH or PASS.
#   Defaults to "PASS"
#
# [*ha_vrrp_auth_password*]
#   (optional) VRRP authentication password. Required if ha_enabled = true.
#   Defaults to $::os_service_default
#
# [*ha_vrrp_advert_int*]
#   (optional) The advertisement interval in seconds.
#   Defaults to '2'
#
# [*agent_mode*]
#   (optional) The working mode for the agent.
#   'legacy': default behavior (without DVR)
#   'dvr': enable DVR for an L3 agent running on compute node (DVR in production)
#   'dvr_snat': enable DVR with centralized SNAT support (DVR for single-host, for testing only)
#   Defaults to 'legacy'
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the l3 config.
#   Defaults to false.
#
# [*availability_zone*]
#   (optional) The availability zone of the agent.
#   Neutron will only schedule routers on the agent based on availability zone
#   Defaults to $::os_service_default
#
# === Deprecated Parameters
#
# [*external_network_bridge*]
#   (optional) Deprecated. The name of the external bridge
#   Defaults to $::os_service_default
#
class neutron::agents::l3 (
  $package_ensure                   = 'present',
  $enabled                          = true,
  $manage_service                   = true,
  $debug                            = false,
  $interface_driver                 = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $gateway_external_network_id      = $::os_service_default,
  $handle_internal_only_routers     = $::os_service_default,
  $metadata_port                    = $::os_service_default,
  $send_arp_for_ha                  = $::os_service_default,
  $periodic_interval                = $::os_service_default,
  $periodic_fuzzy_delay             = $::os_service_default,
  $enable_metadata_proxy            = $::os_service_default,
  $ha_enabled                       = false,
  $ha_vrrp_auth_type                = 'PASS',
  $ha_vrrp_auth_password            = $::os_service_default,
  $ha_vrrp_advert_int               = '3',
  $agent_mode                       = 'legacy',
  $purge_config                     = false,
  $availability_zone                = $::os_service_default,
  # DEPRECATED PARAMETERS
  $external_network_bridge          = $::os_service_default,
) {

  include ::neutron::deps
  include ::neutron::params

  if ! is_service_default ($external_network_bridge) {
    warning('parameter external_network_bridge is deprecated')
  }

  resources { 'neutron_l3_agent_config':
    purge => $purge_config,
  }

  if $ha_enabled {
    neutron_l3_agent_config {
      'DEFAULT/ha_vrrp_auth_type':     value => $ha_vrrp_auth_type;
      'DEFAULT/ha_vrrp_auth_password': value => $ha_vrrp_auth_password;
      'DEFAULT/ha_vrrp_advert_int':    value => $ha_vrrp_advert_int;
    }
  }

  neutron_l3_agent_config {
    'DEFAULT/debug':                            value => $debug;
    'DEFAULT/external_network_bridge':          value => $external_network_bridge;
    'DEFAULT/interface_driver':                 value => $interface_driver;
    'DEFAULT/gateway_external_network_id':      value => $gateway_external_network_id;
    'DEFAULT/handle_internal_only_routers':     value => $handle_internal_only_routers;
    'DEFAULT/metadata_port':                    value => $metadata_port;
    'DEFAULT/send_arp_for_ha':                  value => $send_arp_for_ha;
    'DEFAULT/periodic_interval':                value => $periodic_interval;
    'DEFAULT/periodic_fuzzy_delay':             value => $periodic_fuzzy_delay;
    'DEFAULT/enable_metadata_proxy':            value => $enable_metadata_proxy;
    'DEFAULT/agent_mode':                       value => $agent_mode;
    'AGENT/availability_zone':                  value => $availability_zone;
  }

  if $::neutron::params::l3_agent_package {
    package { 'neutron-l3':
      ensure => $package_ensure,
      name   => $::neutron::params::l3_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-l3':
      ensure => $service_ensure,
      name   => $::neutron::params::l3_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }
}
