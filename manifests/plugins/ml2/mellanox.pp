#
# == Class: neutron::plugins::ml2::mellanox
#
# DEPRECATED !
# Install the Mellanox plugins and generate the config file
# from parameters in the other classes.
#
# === Parameters
#
# [*package_ensure*]
# (optional) The intended state of the networking-mlnx
# package, i.e. any of the possible values of the 'ensure'
# property for a package resource type.
# Defaults to 'present'
#

class neutron::plugins::ml2::mellanox (
  $package_ensure = 'present'
) {
  warning('Support for networking-mlnx has been deprecated')

  include neutron::deps
  include neutron::params
  require neutron::plugins::ml2

  $mlnx_plugin_package = $::neutron::params::mlnx_plugin_package

  ensure_packages($mlnx_plugin_package, {
    ensure => $package_ensure,
    tag    => ['openstack', 'neutron-plugin-ml2-package'],
  })
}
