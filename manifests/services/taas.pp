# This class installs and configures taas Neutron Plugin.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*service_providers*]
#   (optional) Array of allowed service types includes taas
#   Must be in form: <service_type>:<name>:<driver>[:default]
#   Defaults to $facts['os_service_default']
#
# [*quota_tap_service*]
#   (optional) Number of Tap Service instances allowed per tenant.
#   Defaults to $facts['os_service_default']
#
# [*quota_tap_flow*]
#   (optional) Number of Tap flows allowed per tenant.
#   Defaults to $facts['os_service_default']
#
# [*vlan_range_start*]
#   (optional) Starting rantge of TAAS VLAN IDs.
#   Defaults to $facts['os_service_default'].
#
# [*vlan_range_end*]
#   (optional) End rantge of TAAS VLAN IDs.
#   Defaults to $facts['os_service_default'].
#
# [*sync_db*]
#   Whether 'neutron-db-manage' should run to create and/or synchronize the
#   database with neutron-taas specific tables.
#   Default to false
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the taas config.
#   Defaults to false.
#
class neutron::services::taas (
  $package_ensure       = 'present',
  $service_providers    = $facts['os_service_default'],
  $quota_tap_service    = $facts['os_service_default'],
  $quota_tap_flow       = $facts['os_service_default'],
  $vlan_range_start     = $facts['os_service_default'],
  $vlan_range_end       = $facts['os_service_default'],
  Boolean $sync_db      = false,
  Boolean $purge_config = false,
) {
  include neutron::deps
  include neutron::params

  stdlib::ensure_packages( 'neutron-taas', {
    'ensure' => $package_ensure,
    'name'   => $neutron::params::taas_package,
    'tag'    => ['openstack', 'neutron-package'],
  })

  resources { 'neutron_taas_service_config':
    purge => $purge_config,
  }

  if is_service_default($service_providers) {
    $service_providers_real = 'TAAS:TAAS:neutron_taas.services.taas.service_drivers.taas_rpc.TaasRpcDriver:default'
  } else {
    $service_providers_real = $service_providers
  }

  neutron_taas_service_config {
    'service_providers/service_provider': value => $service_providers_real;
    'quotas/quota_tap_service':           value => $quota_tap_service;
    'quotas/quota_tap_flow':              value => $quota_tap_flow;
    'taas/vlan_range_start':              value => $vlan_range_start;
    'taas/vlan_range_end':                value => $vlan_range_end;
  }

  if $sync_db {
    exec { 'taas-db-sync':
      command     => 'neutron-db-manage --subproject tap-as-a-service upgrade head',
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
