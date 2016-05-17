#
# Install the Cisco plugins and generate the config file
# from parameters in the other classes.
#
# === Parameters
#
# [*package_ensure*]
# (optional) The intended state of the neutron-plugin-cisco
# package, i.e. any of the possible values of the 'ensure'
# property for a package resource type.
# Defaults to 'present'
#

class neutron::plugins::ml2::cisco (
  $package_ensure = 'present'
) {

  include ::neutron::deps
  include ::neutron::params
  require ::neutron::plugins::ml2

  if($::osfamily != 'Redhat') {
    # Drivers are only packaged for RedHat at this time
    fail("Unsupported osfamily ${::osfamily}")
  }

  ensure_resource('package', 'python-networking-cisco',
    {
      ensure => $package_ensure,
      tag    => 'openstack',
    }
  )
  warning('python-networking-cisco package management is deprecated, it will be dropped in a future release.')
}
