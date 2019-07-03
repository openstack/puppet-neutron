#
# == Class: neutron::agents::ml2::mlnx
#
# Setups MLNX neutron agent when using ML2 plugin
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to 'present'
#
# [*enabled*]
#   (required) Whether or not to enable the MLNX Agent
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*physical_device_mappings*]
#   (optional) Array of <physical_network>:<physical device>
#   All physical networks listed in network_vlan_ranges
#   on the server should have mappings to appropriate
#   interfaces on each agent.
#   Value should be of type array, Defaults to $::os_service_default
#
# [*polling_interval*]
#   (optional) The number of seconds the agent will wait between
#   polling for local device changes.
#   Defaults to '2"
#

class neutron::agents::ml2::mlnx (
  $package_ensure             = 'present',
  $enabled                    = true,
  $manage_service             = true,
  $physical_device_mappings   = $::os_service_default,
  $polling_interval           = 2,
) {

  include ::neutron::deps
  include ::neutron::params

  $mlnx_agent_package          = $::neutron::params::mlnx_agent_package
  $mlnx_agent_service          = $::neutron::params::mlnx_agent_service
  $eswitchd_service            = $::neutron::params::eswitchd_service

  neutron_mlnx_agent_config {
    'eswitch/physical_device_mappings': value => pick(join(any2array($physical_device_mappings), ','), $::os_service_default);
    'agent/polling_interval':           value => $polling_interval;
  }

  eswitchd_config {
    'DAEMON/fabrics': value => pick(join(any2array($physical_device_mappings), ','), $::os_service_default);
  }

  package { $mlnx_agent_package:
    ensure => $package_ensure,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { $mlnx_agent_service:
    ensure => $service_ensure,
    name   => $mlnx_agent_service,
    enable => $enabled,
    tag    => 'neutron-service',
  }

  service { $eswitchd_service:
    ensure => $service_ensure,
    name   => $eswitchd_service,
    enable => $enabled,
    tag    => 'neutron-service',
  }

}
