# This class installs and configures the OVN Neutron plugin
#
# === Parameters
#
# [*ovn_nb_connection*]
#   (optional) The connection string for the OVN_Northbound OVSDB.
#   Defaults to 'tcp:127.0.0.1:6641'
#
# [*ovn_sb_connection*]
#   (optional) The connection string for the OVN_Southbound OVSDB
#   Defaults to 'tcp:127.0.0.1:6642'
#
# [*package_ensure*]
#   (optional) The intended state of the python-networking-odl
#   package, i.e. any of the possible values of the 'ensure'
#   property for a package resource type.
#   Defaults to 'present'
#
# [*ovsdb_connection_timeout*]
#   (optional) Timeout in seconds for the OVSDB connection transaction
#   Defaults to $::os_service_default
#
# [*neutron_sync_mode*]
#   (optional) The synchronization mode of OVN with Neutron DB.
#   Valid values are - 'log', 'off', 'repair'
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
#   Valid values are 'ovs', 'vhostuser'
#   Defaults to $::os_service_default

class neutron::plugins::ml2::ovn(
  $ovn_nb_connection        = $::os_service_default,
  $ovn_sb_connection        = $::os_service_default,
  $package_ensure           = 'present',
  $ovsdb_connection_timeout = $::os_service_default,
  $neutron_sync_mode        = $::os_service_default,
  $ovn_l3_mode              = $::os_service_default,
  $vif_type                 = $::os_service_default,
  ) {

  include ::neutron::deps
  require ::neutron::plugins::ml2

  if ! is_service_default($ovn_l3_mode) {
    validate_bool($ovn_l3_mode)
  }

  if ! ( $vif_type in ['ovs', 'vhostuser', $::os_service_default] ) {
    fail( 'Invalid value for vif_type parameter' )
  }

  if ! ( $neutron_sync_mode in ['off', 'log', 'repair', $::os_service_default] ) {
    fail( 'Invalid value for neutron_sync_mode parameter' )
  }

  ensure_resource('package', $::neutron::params::ovn_plugin_package,
    {
      ensure => $package_ensure,
      tag    => 'openstack',
    }
  )

  neutron_plugin_ml2 {
    'ovn/ovn_nb_connection'        : value => $ovn_nb_connection;
    'ovn/ovn_sb_connection'        : value => $ovn_sb_connection;
    'ovn/ovsdb_connection_timeout' : value => $ovsdb_connection_timeout;
    'ovn/neutron_sync_mode'        : value => $neutron_sync_mode;
    'ovn/ovn_l3_mode'              : value => $ovn_l3_mode;
    'ovn/vif_type'                 : value => $vif_type;
  }
}
