# This class installs and configures fwaas Neutron Plugin.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*service_providers*]
#   (optional) Array of allowed service types includes fwaas
#   Must be in form: <service_type>:<name>:<driver>[:default]
#   Defaults to 'FIREWALL_V2:fwaas_db:neutron_fwaas.services.firewall.service_drivers.agents.agents.FirewallAgentDriver:default'.
#
# [*sync_db*]
#   (optional) Whether 'neutron-db-manage' should run to create and/or
#   synchronize the database with neutron-fwaas specific tables.
#   Default to false.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the fwaas config.
#   Defaults to false.
#
class neutron::services::fwaas (
  Stdlib::Ensure::Package $package_ensure = 'present',
  $service_providers                      = 'FIREWALL_V2:fwaas_db:neutron_fwaas.services.firewall.service_drivers.agents.agents.FirewallAgentDriver:default',
  Boolean $sync_db                        = false,
  Boolean $purge_config                   = false,
) {
  include neutron::deps
  include neutron::params

  stdlib::ensure_packages( 'neutron-fwaas', {
    'ensure' => $package_ensure,
    'name'   => $neutron::params::fwaas_package,
    'tag'    => ['openstack', 'neutron-package'],
  })

  resources { 'neutron_fwaas_service_config':
    purge => $purge_config,
  }

  neutron_fwaas_service_config {
    'service_providers/service_provider': value => $service_providers;
  }

  if $sync_db {
    exec { 'fwaas-db-sync':
      command     => 'neutron-db-manage --subproject neutron-fwaas upgrade head',
      path        => '/usr/bin',
      user        => $neutron::params::user,
      subscribe   => [
        Anchor['neutron::install::end'],
        Anchor['neutron::config::end'],
        Anchor['neutron::dbsync::begin']
      ],
      notify      => Anchor['neutron::dbsync::end'],
      refreshonly => true,
    }
  }
}
