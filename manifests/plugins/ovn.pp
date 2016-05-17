# This class installs and configures the OVN Neutron plugin
#
# === Parameters
#
# [*ovsdb_connection*]
#   (required) The connection string for the native OVSDB backend.
#
# [*ovsdb_connection_timeout*]
#   (optional) Timeout in seconds for the OVSDB connection transaction
#   Defaults to $::os_service_default
#
# [*neutron_sync_mode*]
#   (optional) The synchronization mode of OVN with Neutron DB.
#   Valid values are - ['log', 'off', 'repair']
#   off - synchronization is off
#   log - during neutron-server startup check to see if OVN is in sync with
#         the Neutron database. Log warnings for any inconsistencies found so
#         that an admin can investigate.
#   repair - during neutron-server startup, automatically create resources
#            found in Neutron but not in OVN. Also remove resources from OVN
#            that are no longer in Neutron.
#   Defaults to $::os_service_default
#
# [*ovn_l3_mode*]
#   (optional) Whether to use OVN native L3 support. Do not change the
#   value for existing deployments that contain routers.
#   Type: boolean
#   Defaults to $::os_service_default
#
# [*vif_type*]
#   (optional) Type of VIF to be used for ports.
#   Valid values are ['ovs', 'vhostuser']
#   Defaults to $::os_service_default

class neutron::plugins::ovn(
  $ovsdb_connection,
  $ovsdb_connection_timeout = $::os_service_default,
  $neutron_sync_mode        = $::os_service_default,
  $ovn_l3_mode              = $::os_service_default,
  $vif_type                 = $::os_service_default,
  ) {

  include ::neutron::deps
  include ::neutron::params

  if ! is_service_default($ovn_l3_mode) {
    validate_bool($ovn_l3_mode)
  }

  if ! ( $vif_type in ['ovs', 'vhostuser', $::os_service_default] ) {
    fail( 'Invalid value for vif_type parameter' )
  }

  if ! ( $neutron_sync_mode in ['off', 'log', 'repair', $::os_service_default] ) {
    fail( 'Invalid value for neutron_sync_mode parameter' )
  }

  package {'neutron-plugin-ovn':
    ensure => present,
    name   => $::neutron::params::ovn_plugin_package,
    tag    => ['neutron-package', 'openstack'],
  }

  ensure_resource('file', '/etc/neutron/plugins/networking-ovn', {
    ensure => directory,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640'}
  )

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path  => '/etc/default/neutron-server',
      match => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line  => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::ovn_config_file}",
      tag   => 'neutron-file-line',
    }
  }

  if $::osfamily == 'Redhat' {
    file { '/etc/neutron/plugin.ini':
      ensure  => link,
      target  => $::neutron::params::ovn_config_file,
      require => Package[$::neutron::params::ovn_plugin_package],
      tag     => 'neutron-config-file',
    }
  }

  neutron_plugin_ovn {
    'ovn/ovsdb_connection':         value => $ovsdb_connection;
    'ovn/ovsdb_connection_timeout': value => $ovsdb_connection_timeout;
    'ovn/neutron_sync_mode':        value => $neutron_sync_mode;
    'ovn/ovn_l3_mode':              value => $ovn_l3_mode;
    'ovn/vif_type':                 value => $vif_type;
  }
}
