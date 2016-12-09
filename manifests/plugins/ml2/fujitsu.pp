#
# Install the Fujitsu ML2 plugin.
#
# === Parameters
#
# [*package_ensure*]
# (optional) The intended state of the Fujitsu ML2 plugin package
# i.e. any of the possible values of the 'ensure' property for a
# package resource type.  Defaults to 'present'
#

class neutron::plugins::ml2::fujitsu (
  $package_ensure = 'present'
) {

  include ::neutron::deps

  ensure_resource('package', 'python-networking-fujitsu',
    {
      ensure => $package_ensure,
      tag    => 'openstack',
    }
  )
}
