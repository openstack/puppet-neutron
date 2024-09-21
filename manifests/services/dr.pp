# This class installs and configures dynamic routing Neutron Plugin.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*bgp_drscheduler_driver*]
#   (optional) Driver used for scheduling BGP speakers to BGP DrAgent.
#   Defaults to $facts['os_service_default']
#
# [*sync_db*]
#   Whether 'neutron-db-manage' should run to create and/or synchronize the
#   database with neutron-vpnaas specific tables.
#   Default to false
#
class neutron::services::dr (
  $package_ensure         = 'present',
  $bgp_drscheduler_driver = $facts['os_service_default'],
  Boolean $sync_db        = false,
) {

  include neutron::deps
  include neutron::params

  ensure_packages('neutron-dynamic-routing', {
    ensure => $package_ensure,
    name   => $::neutron::params::dynamic_routing_package,
    tag    => ['openstack', 'neutron-package'],
  })

  neutron_config {
    'DEFAULT/bgp_drscheduler_driver': value => $bgp_drscheduler_driver;
  }

  if $sync_db {
    exec { 'dr-db-sync':
      command     => 'neutron-db-manage --subproject neutron-dynamic-routing upgrade head',
      path        => '/usr/bin',
      user        => $::neutron::params::user,
      subscribe   => [
        Anchor['neutron::install::end'],
        Anchor['neutron::config::end'],
        Anchor['neutron::dbsync::begin']
      ],
      notify      => Anchor['neutron::dbsync::end'],
      refreshonly => true
    }
  }
}
