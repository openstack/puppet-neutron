# == DEPRECATED
# This class has been deprecated in favor of neutron::plugins::ml2::ovn
#
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
#   Valid values are 'ovs','vhostuser'
#   Defaults to $::os_service_default

class neutron::plugins::ovn(
  $ovsdb_connection,
  $ovsdb_connection_timeout = $::os_service_default,
  $neutron_sync_mode        = $::os_service_default,
  $ovn_l3_mode              = $::os_service_default,
  $vif_type                 = $::os_service_default,
  ) {

  warning('neutron::plugins::ovn is deprecated in favor of neutron::plugins::ml2::ovn')

  class { '::neutron::plugins::ml2::ovn':
    ovn_nb_connection        => $ovsdb_connection,
    ovsdb_connection_timeout => $ovsdb_connection_timeout,
    neutron_sync_mode        => $neutron_sync_mode,
    ovn_l3_mode              => $ovn_l3_mode,
    vif_type                 => $vif_type
  }

}
