# == Class: neutron::agents::ml2::macvtap
#
# Setups Macvtap Neutron agent for ML2 plugin.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Package ensure state.
#   Defaults to 'present'.
#
# [*enabled*]
#   (required) Whether or not to enable the agent.
#   Defaults to true.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*polling_interval*]
#   (optional) The number of seconds the agent will wait between
#   polling for local device changes.
#   Defaults to $::os_service_default.
#
# [*physical_interface_mappings*]
#   (optional) List of <physical_network>:<physical_interface>
#   tuples mapping physical network names to agent's node-specific physical
#   network interfaces. Defaults to empty list.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the macvtap config.
#   Defaults to false.
#
class neutron::agents::ml2::macvtap (
  $package_ensure              = 'present',
  $enabled                     = true,
  $manage_service              = true,
  $polling_interval            = $::os_service_default,
  $physical_interface_mappings = [],
  $purge_config                = false,
) {

  validate_legacy(Array, 'validate_array', $physical_interface_mappings)

  include neutron::deps
  include neutron::params

  resources { 'neutron_agent_macvtap':
    purge => $purge_config,
  }

  neutron_agent_macvtap {
    'agent/polling_interval':        value => $polling_interval;
    # NOTE(tkajinam): macvtap supports only noop firewall driver.
    'securitygroup/firewall_driver': value => 'noop';
  }

  if size($physical_interface_mappings) > 0 {
    neutron_agent_macvtap {
      'macvtap/physical_interface_mappings': value => join(any2array($physical_interface_mappings), ',');
    }
  } else {
    neutron_agent_macvtap {
      'macvtap/physical_interface_mappings': ensure => absent;
    }
  }

  package { 'neutron-plugin-macvtap-agent':
    ensure => $package_ensure,
    name   => $::neutron::params::macvtap_agent_package,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-plugin-macvtap-agent':
      ensure => $service_ensure,
      name   => $::neutron::params::macvtap_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }
}
