# This class installs and configures vpnaas Neutron Plugin.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*service_providers*]
#   (optional) Array of allowed service types includes vpnaas
#   Must be in form: <service_type>:<name>:<driver>[:default]
#   Defaults to $facts['os_service_default']
#
# [*vpn_scheduler_driver*]
#   (optional) Driver to use for scheduling router to a VPN agent.
#   Defaults to $facts['os_service_default']
#
# [*vpn_auto_schedule*]
#   (optional) Allow auto scheduling of routers to VPN agent.
#   Defaults to $facts['os_service_default']
#
# [*allow_automatic_vpnagent_failover*]
#   (optional) Automatically reschedule routers from offline VPN agents to
#   online VPN agents.
#   Defaults to $facts['os_service_default']
#
# [*sync_db*]
#   Whether 'neutron-db-manage' should run to create and/or synchronize the
#   database with neutron-vpnaas specific tables.
#   Default to false
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the vpnaas config.
#   Defaults to false.
#
class neutron::services::vpnaas (
  $package_ensure                    = 'present',
  $service_providers                 = $facts['os_service_default'],
  $vpn_scheduler_driver              = $facts['os_service_default'],
  $vpn_auto_schedule                 = $facts['os_service_default'],
  $allow_automatic_vpnagent_failover = $facts['os_service_default'],
  Boolean $sync_db                   = false,
  Boolean $purge_config              = false,
) {
  include neutron::deps
  include neutron::params

  stdlib::ensure_packages( 'neutron-vpnaas-agent', {
    'ensure' => $package_ensure,
    'name'   => $neutron::params::vpnaas_agent_package,
    'tag'    => ['openstack', 'neutron-package'],
  })

  resources { 'neutron_vpnaas_service_config':
    purge => $purge_config,
  }

  if is_service_default($service_providers) {
    $service_providers_real = 'VPN:openswan:neutron_vpnaas.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default'
  } else {
    $service_providers_real = $service_providers
  }

  neutron_vpnaas_service_config {
    'service_providers/service_provider':        value => $service_providers_real;
    'DEFAULT/vpn_scheduler_driver':              value => $vpn_scheduler_driver;
    'DEFAULT/vpn_auto_schedule':                 value => $vpn_auto_schedule;
    'DEFAULT/allow_automatic_vpnagent_failover': value => $allow_automatic_vpnagent_failover;
  }

  if $sync_db {
    exec { 'vpnaas-db-sync':
      command     => 'neutron-db-manage --subproject neutron-vpnaas upgrade head',
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
