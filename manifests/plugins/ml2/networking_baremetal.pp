# This class installs and configures the networking-baremetal Neutron plugin
#
# == Class: neutron::plugins::ml2::networking_baremetal
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The intended state of the python-networking-baremetal
#   package, i.e. any of the possible values of the 'ensure'
#   property for a package resource type.
#   Defaults to 'present'
#
class neutron::plugins::ml2::networking_baremetal (
  $package_ensure = 'present',
) {
  include neutron::deps
  include neutron::params

  package { 'python-networking-baremetal':
    ensure => $package_ensure,
    name   => $neutron::params::networking_baremetal_package,
    tag    => ['openstack', 'neutron-plugin-ml2-package'],
  }
}
