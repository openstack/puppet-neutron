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
# Defaults to undef
# Example: 'admin'
#
# [*odl_password*]
# (optional) The opendaylight controller password
# Defaults to undef
# Example: 'admin'
#
# [*odl_url*]
# (optional) The opendaylight controller neutron URL
# Defaults to undef
# Example: 'http://127.0.0.1:8080/controller/nb/v2/neutron'
#
class neutron::plugins::ml2::opendaylight (
  $package_ensure    = 'present',
  $odl_username      = undef,
  $odl_password      = undef,
  $odl_url           = undef
) {
  require ::neutron::plugins::ml2

  ensure_resource('package', 'python-networking-odl',
    {
      ensure => $package_ensure,
      tag    => 'openstack',
    }
  )

  if ($odl_username) {
    neutron_plugin_ml2 { 'ml2_odl/username': value => $odl_username; }
  } else {
    neutron_plugin_ml2 { 'ml2_odl/username': ensure => absent; }
  }

  if ($odl_password) {
    neutron_plugin_ml2 { 'ml2_odl/password': value => $odl_password; }
  } else {
    neutron_plugin_ml2 { 'ml2_odl/password': ensure => absent; }
  }

  if ($odl_url) {
    neutron_plugin_ml2 { 'ml2_odl/url': value => $odl_url; }
  } else {
    neutron_plugin_ml2 { 'ml2_odl/url': ensure => absent; }
  }
}
