#
# Install the OpenDaylight and generate config file
# from parameters in the other classes.
#
# === Parameters
#
# [*package_ensure*]
# (optional) The intended state of the python-networking-odl
# package, i.e. any of the possible values of the 'ensure'
# property for a package resource type.
# Defaults to 'present'
#
# [*odl_username*]
# (optional) The opendaylight controller username
# Defaults to $::os_service_default
# Example: 'admin'
#
# [*odl_password*]
# (optional) The opendaylight controller password
# Defaults to $::os_service_default
# Example: 'admin'
#
# [*odl_url*]
# (optional) The opendaylight controller neutron URL
# Defaults to $::os_service_default
# Example: 'http://127.0.0.1:8080/controller/nb/v2/neutron'
#
# [*ovsdb_connection*]
# (optional) The URI used to connect to the local OVSDB server
# Defaults to 'tcp:127.0.0.1:6639'
#
class neutron::plugins::ml2::opendaylight (
  $package_ensure     = 'present',
  $odl_username       = $::os_service_default,
  $odl_password       = $::os_service_default,
  $odl_url            = $::os_service_default,
  $ovsdb_connection   = 'tcp:127.0.0.1:6639',
) {

  include ::neutron::deps
  require ::neutron::plugins::ml2

  ensure_resource('package', 'python-networking-odl',
    {
      ensure => $package_ensure,
      tag    => 'openstack',
    }
  )

  neutron_plugin_ml2 {
    'ml2_odl/username': value => $odl_username;
    'ml2_odl/password': value => $odl_password;
    'ml2_odl/url':      value => $odl_url;
  }

  neutron_config {
    'OVS/ovsdb_connection': value => $ovsdb_connection;
  }
}
