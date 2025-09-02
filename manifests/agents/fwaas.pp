# == Class: neutron::agents:fwaas
#
# Setups Neutron FWaaS agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*driver*]
#   (optional) Name of the FWaaS driver.
#   Defaults to $facts['os_service_default'].
#
# [*enabled*]
#   (optional) Enable FWaaS.
#   Defaults to $facts['os_service_default'].
#
# [*conntrack_driver*]
#   (optional) Name of the firewall l3 driver.
#   Defaults to $facts['os_service_default'].
#
# [*firewall_l2_driver*]
#   (optional) Name of the firewall l2 driver.
#   Defaults to $facts['os_service_default'].
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the fwaas config.
#   Defaults to false.
#
class neutron::agents::fwaas (
  $package_ensure       = present,
  $driver               = $facts['os_service_default'],
  $enabled              = $facts['os_service_default'],
  $conntrack_driver     = $facts['os_service_default'],
  $firewall_l2_driver   = $facts['os_service_default'],
  Boolean $purge_config = false,
) {
  include neutron::deps
  include neutron::params

  resources { 'neutron_fwaas_agent_config':
    purge => $purge_config,
  }

  # NOTE(tkajinam): options for l3 agent extension
  neutron_fwaas_agent_config {
    'fwaas/driver':             value => $driver;
    'fwaas/enabled':            value => $enabled;
    'fwaas/conntrack_driver':   value => $conntrack_driver;
    'fwaas/firewall_l2_driver': value => $firewall_l2_driver;
  }
  Neutron_fwaas_agent_config<||> ~> Service<| title == 'neutron-l3' |>

  # NOTE(tkajinam): options for l2 agent extension
  neutron_plugin_ml2 {
    'fwaas/driver':             value => $driver;
    'fwaas/enabled':            value => $enabled;
    'fwaas/conntrack_driver':   value => $conntrack_driver;
    'fwaas/firewall_l2_driver': value => $firewall_l2_driver;
  }

  stdlib::ensure_packages( 'neutron-fwaas', {
    'ensure' => $package_ensure,
    'name'   => $neutron::params::fwaas_package,
    'tag'    => ['openstack', 'neutron-package'],
  })
}
