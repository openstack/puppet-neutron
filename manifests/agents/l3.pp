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
#   Defaults to $facts['os_service_default']
#
# [*interface_driver*]
#   (optional) The driver used to manage the virtual interface.
#   Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*handle_internal_only_routers*]
#   (optional) L3 Agent will handle non-external routers
#   Defaults to $facts['os_service_default']
#
# [*metadata_port*]
#   (optional) The port of the metadata server
#   Defaults to $facts['os_service_default']
#
# [*periodic_interval*]
#   (optional) seconds between re-sync routers' data if needed
#   Defaults to $facts['os_service_default']
#
# [*periodic_fuzzy_delay*]
#   (optional) seconds to start to sync routers' data after starting agent
#   Defaults to $facts['os_service_default']
#
# [*enable_metadata_proxy*]
#   (optional) can be set to False if the Nova metadata server is not available
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
#
# [*extensions*]
#   (optional) List of the L3 agent extensions to enable.
#   Defaults to $facts['os_service_default']
#
# [*report_interval*]
#   (optional) Set the agent report interval. By default the global report
#   interval in neutron.conf ([agent]/report_interval) is used. This parameter
#   can be used to override the reporting interval for l3-agent.
#   Defaults to $facts['os_service_default']
#
# [*rpc_response_max_timeout*]
#   (Optional) Maximum seconds to wait for a response from an RPC call
#   Defaults to: $facts['os_service_default']
#
# [*radvd_user*]
#   (optional) The username passed to radvd, used to drop root privileges and
#   change user ID to username and group ID to the primary group of username.
#   If no user specified, the user executing the L3 agent will be passed. If
#   "root" specified, because radvd is spawned as root, no "username" parameter
#   will be passed.
#   Defaults to $facts['os_service_default']
#
# [*ovs_integration_bridge*]
#   (optional) Name of Open vSwitch bridge to use
#   Defaults to $facts['os_service_default']
#
# [*network_log_rate_limit*]
#   (Optional) Maximum packets logging per second.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#   Minimum possible value is 100.
#
# [*network_log_burst_limit*]
#   (Optional) Maximum number of packets per rate_limit.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#   Minimum possible value is 25.
#
# [*network_log_local_output_log_base*]
#   (Optional) Output logfile path on agent side, default syslog file.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#
class neutron::agents::l3 (
  $package_ensure                    = 'present',
  Boolean $enabled                   = true,
  Boolean $manage_service            = true,
  $debug                             = $facts['os_service_default'],
  $interface_driver                  = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $handle_internal_only_routers      = $facts['os_service_default'],
  $metadata_port                     = $facts['os_service_default'],
  $periodic_interval                 = $facts['os_service_default'],
  $periodic_fuzzy_delay              = $facts['os_service_default'],
  $enable_metadata_proxy             = $facts['os_service_default'],
  Boolean $ha_enabled                = false,
  $ha_vrrp_auth_type                 = 'PASS',
  $ha_vrrp_auth_password             = $facts['os_service_default'],
  $ha_vrrp_advert_int                = '3',
  $agent_mode                        = 'legacy',
  $purge_config                      = false,
  $availability_zone                 = $facts['os_service_default'],
  $extensions                        = $facts['os_service_default'],
  $report_interval                   = $facts['os_service_default'],
  $rpc_response_max_timeout          = $facts['os_service_default'],
  $radvd_user                        = $facts['os_service_default'],
  $ovs_integration_bridge            = $facts['os_service_default'],
  $network_log_rate_limit            = $facts['os_service_default'],
  $network_log_burst_limit           = $facts['os_service_default'],
  $network_log_local_output_log_base = $facts['os_service_default'],
) {

  include neutron::deps
  include neutron::params

  resources { 'neutron_l3_agent_config':
    purge => $purge_config,
  }

  if $ha_enabled {
    neutron_l3_agent_config {
      'DEFAULT/ha_vrrp_auth_type':     value => $ha_vrrp_auth_type;
      'DEFAULT/ha_vrrp_auth_password': value => $ha_vrrp_auth_password, secret => true;
      'DEFAULT/ha_vrrp_advert_int':    value => $ha_vrrp_advert_int;
    }
  } else {
    neutron_l3_agent_config {
      'DEFAULT/ha_vrrp_auth_type':     ensure => absent;
      'DEFAULT/ha_vrrp_auth_password': ensure => absent;
      'DEFAULT/ha_vrrp_advert_int':    ensure => absent;
    }
  }

  neutron_l3_agent_config {
    'DEFAULT/debug':                        value => $debug;
    'DEFAULT/interface_driver':             value => $interface_driver;
    'DEFAULT/handle_internal_only_routers': value => $handle_internal_only_routers;
    'DEFAULT/metadata_port':                value => $metadata_port;
    'DEFAULT/periodic_interval':            value => $periodic_interval;
    'DEFAULT/periodic_fuzzy_delay':         value => $periodic_fuzzy_delay;
    'DEFAULT/enable_metadata_proxy':        value => $enable_metadata_proxy;
    'DEFAULT/agent_mode':                   value => $agent_mode;
    'DEFAULT/radvd_user':                   value => $radvd_user;
    'ovs/integration_bridge':               value => $ovs_integration_bridge;
    'agent/availability_zone':              value => $availability_zone;
    'agent/extensions':                     value => join(any2array($extensions), ',');
    'agent/report_interval':                value => $report_interval;
    'DEFAULT/rpc_response_max_timeout':     value => $rpc_response_max_timeout;
    'network_log/rate_limit':               value => $network_log_rate_limit;
    'network_log/burst_limit':              value => $network_log_burst_limit;
    'network_log/local_output_log_base':    value => $network_log_local_output_log_base;
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
