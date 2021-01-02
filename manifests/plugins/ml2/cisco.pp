#
# DEPRECATED !
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

  warning('Support for networking-cisco has been deprecated and has no effect')
}
