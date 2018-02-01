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
# [*port_binding_controller*]
# (optional) Name of the controller to be used for port binding.
# Defaults to $::os_service_default
#
# [*odl_hostconf_uri*]
# (optional) Path for ODL host configuration REST interface.
# Defaults to $::os_service_default
#
# [*odl_features*]
# (optional) List of ODL features to enable
# Defaults to $::os_service_default
#
# === Deprecated Parameters
#
# [*ovsdb_connection*]
# (optional) Deprecated.  The URI used to connect to the local OVSDB server
# Defaults to 'tcp:127.0.0.1:6639'
#
class neutron::plugins::ml2::opendaylight (
  $package_ensure            = 'present',
  $odl_username              = $::os_service_default,
  $odl_password              = $::os_service_default,
  $odl_url                   = $::os_service_default,
  $ovsdb_connection          = 'tcp:127.0.0.1:6639',
  $port_binding_controller   = $::os_service_default,
  $odl_hostconf_uri          = $::os_service_default,
  $odl_features              = $::os_service_default,
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
    'ml2_odl/username':                value => $odl_username;
    'ml2_odl/password':                value => $odl_password, secret => true;
    'ml2_odl/url':                     value => $odl_url;
    'ml2_odl/port_binding_controller': value => $port_binding_controller;
    'ml2_odl/odl_hostconf_uri':        value => $odl_hostconf_uri;
    'ml2_odl/odl_features':            value => join(any2array($odl_features), ',');
  }

  if $ovsdb_connection != 'tcp:127.0.0.1:6639' {
    warning('The ovsdb_connection parameter is deprecated and will be removed in future releases')
  }

  neutron_config {
    'OVS/ovsdb_connection': value => $ovsdb_connection;
  }
}
