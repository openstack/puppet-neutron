# == Class: quantum::client
#
# Manages the quantum client package on systems
#
# === Parameters:
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
class quantum::client (
  $package_ensure = present
) {

  include quantum::params

  package { 'python-quantumclient':
    name   => $::quantum::params::client_package_name,
    ensure => $package_ensure
  }

}
