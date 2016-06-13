#
# Install the Big Switch ML2 plugin.
#
# === Parameters
#
# [*package_ensure*]
# (optional) The intended state of the Big Switch ML2 plugin package
# (python-bsnstacklib) package, i.e. any of the possible values of the
# 'ensure' property for a package resource type.  Defaults to
# 'present'
#
class neutron::plugins::ml2::bigswitch (
  $package_ensure = 'present',
) {

  include ::neutron::deps
  include ::neutron::params
  require ::neutron::plugins::ml2

  if($::osfamily != 'Redhat') {
    # Drivers are only packaged for RedHat at this time
    fail("Unsupported osfamily ${::osfamily}")
  }

  ensure_packages('python-networking-bigswitch',
    {
      ensure => $package_ensure,
      tag    => 'openstack',
    }
  )
  warning('python-networking-bigswitch package management is deprecated, it will be dropped in a future release.')
}
