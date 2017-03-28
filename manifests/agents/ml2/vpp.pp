# == Class: neutron::agents::ml2::vpp
#
# Configure networking-vpp Neutron agent for ML2 plugin.
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
# [*physnets*]
#   (optional) Comma-separated list of <physical_network>:<physical_interface>
#   tuples mapping physical network names to agent's node-specific physical
#   network interfaces. Defaults to $::os_service_default.
#
# [*etcd_host*]
#   (optional) etcd server host name/ip
#   Defaults to $::os_service_default.
#
# [*etcd_port*]
#   (optional) etcd server listening port.
#   Defaults to $::os_service_default.
#
# [*etcd_user*]
#   (optional) User name for etcd authentication
#   Defaults to $::os_service_default.
#
# [*etcd_pass*]
#   (optional) Password for etcd authentication
#   Defaults to $::os_service_default.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the vpp config.
#   Defaults to false.
#
class neutron::agents::ml2::vpp (
  $package_ensure = 'present',
  $enabled        = true,
  $manage_service = true,
  $physnets       = $::os_service_default,
  $etcd_host      = $::os_service_default,
  $etcd_port      = $::os_service_default,
  $etcd_user      = $::os_service_default,
  $etcd_pass      = $::os_service_default,
  $purge_config   = false,
) {
  include ::neutron::deps
  include ::neutron::params

  resources { 'neutron_agent_vpp':
    purge => $purge_config,
  }

  neutron_agent_vpp {
    'ml2_vpp/physnets':  value => $physnets;
    'ml2_vpp/etcd_host': value => $etcd_host;
    'ml2_vpp/etcd_port': value => $etcd_port;
    'ml2_vpp/etcd_user': value => $etcd_user;
    'ml2_vpp/etcd_pass': value => $etcd_pass;
    'DEFAULT/host':      value => $::hostname;
  }

  package { 'neutron-vpp-agent':
    ensure => $package_ensure,
    name   => $::neutron::params::vpp_plugin_package,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'neutron-vpp-agent-service':
    ensure => $service_ensure,
    name   => $::neutron::params::vpp_agent_service,
    enable => $enabled,
    tag    => ['neutron-service'],
  }
}
