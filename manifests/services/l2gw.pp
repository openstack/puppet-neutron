# This class installs and configures l2gw Neutron Plugin.
#
# === Parameters
#
# [*default_interface_name*]
#   (optional) default interface name of the l2 gateway
#   Defaults to $::os_service_default
#   Example: FortyGigE1/0/1
#
# [*default_device_name*]
#   (optional) default device name of the l2 gateway
#   Defaults to $::os_service_default
#   Example: Switch1
#
# [*quota_l2_gateway*]
#   (optional) quota of the l2 gateway
#   Defaults to $::os_service_default
#   Example: 10
#
# [*periodic_monitoring_interval*]
#   (optional) The periodic interval at which the plugin
#   checks for the monitoring L2 gateway agent
#   Defaults to $::os_service_default
#   Example: 5
#
# [*service_providers*]
#   (optional) Array of allowed service types includes L2GW
#   Must be in form: <service_type>:<name>:<driver>[:default]
#   Defaults to $::os_service_default
#
# [*sync_db*]
#   Whether 'l2gw-db-sync' should run to create and/or synchronize the
#   database with networking-l2gw specific tables.
#   Default to false
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the l2gw config.
#   Defaults to false.
#
class neutron::services::l2gw (
  $default_interface_name       = $::os_service_default,
  $default_device_name          = $::os_service_default,
  $quota_l2_gateway             = $::os_service_default,
  $periodic_monitoring_interval = $::os_service_default,
  $service_providers            = $::os_service_default,
  $sync_db                      = false,
  $package_ensure               = 'present',
  $purge_config                 = false,
) {

  include ::neutron::deps
  include ::neutron::params

  if !is_service_default($service_providers) {
    validate_array($service_providers)
  }

  ensure_resource( 'package', 'python-networking-l2gw', {
    'ensure' => $package_ensure,
    'name'   => $::neutron::params::l2gw_package,
    'tag'    => ['neutron-package', 'openstack'],
  })

  resources { 'neutron_l2gw_service_config':
    purge => $purge_config,
  }

  neutron_l2gw_service_config {
      'DEFAULT/default_interface_name':               value => $default_interface_name;
      'DEFAULT/default_device_name':                  value => $default_device_name;
      'DEFAULT/quota_l2_gateway':                     value => $quota_l2_gateway;
      'DEFAULT/periodic_monitoring_interval':         value => $periodic_monitoring_interval;
      'service_providers/service_provider':           value => $service_providers;
  }

  if $sync_db {
    Package<| title == $::neutron::params::l2gw_package |> ~> Exec['l2gw-db-sync']
    exec { 'l2gw-db-sync':
      command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --subproject networking-l2gw upgrade head',
      path        => '/usr/bin',
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
