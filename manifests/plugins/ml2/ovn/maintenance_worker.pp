# == Class: neutron::plugins::ml2::ovn::maintenance_worker
#
# Setup and configure neutron OVN maintenance worker.
#
# === Parameters
#
# [*package_ensure*]
#   Ensure state of the package. Defaults to 'present'.
#
# [*enabled*]
#   State of the service. Defaults to true.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
class neutron::plugins::ml2::ovn::maintenance_worker (
  Stdlib::Ensure::Package $package_ensure = 'present',
  Boolean $enabled                        = true,
  Boolean $manage_service                 = true,
) {
  include neutron::params

  package { 'neutron-ovn-maintenance-worker':
    ensure => $package_ensure,
    name   => $neutron::params::ovn_maintenance_worker_package,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-ovn-maintenance-worker':
      ensure => $service_ensure,
      name   => $neutron::params::ovn_maintenance_worker_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }
}
