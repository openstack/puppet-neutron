# == Class: neutron::client
#
# Manages the neutron client package on systems
#
# === Parameters:
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
class neutron::client (
  $package_ensure = present
) {

  include neutron::deps
  include neutron::params

  warning("The neutron::client class has been deprecated and will be removed \
in a future release.")

  package { 'python-neutronclient':
    ensure => $package_ensure,
    name   => $::neutron::params::client_package,
    tag    => 'openstack',
  }

  include openstacklib::openstackclient

}
