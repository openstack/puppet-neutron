#
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

  include neutron::deps
  include neutron::params
  require neutron::plugins::ml2

  if($::osfamily != 'RedHat') {
    # Drivers are only packaged for RedHat at this time
    fail("Unsupported osfamily ${::osfamily}")
  }

  $mlnx_plugin_package = $::neutron::params::mlnx_plugin_package

  ensure_packages($mlnx_plugin_package, {
    ensure => $package_ensure,
    tag    => ['openstack'],
  })

  # NOTE(tkajinam): CentOS/RHEL uses the same package for both agent and
  #                 plugin. This is required to avoid conflict with
  #                 neutron::agens::ml2::mlnx
  Package<| title == $mlnx_plugin_package |> { tag +> 'neutron-plugin-ml2-package' }
}
