# == Class: quantum::server
#
# Setup and configure the quantum API endpoint
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*log_file*]
#   (optional) Where to log
#
# [*log_dir*]
#   (optional) Directory to store logs
#   Defaults to /var/log/quantum
#
# [*auth_password*]
#   (optional) The password to use for authentication (keystone)
#   Defaults to false. Set a value unless you are using noauth
#
# [*auth_type*]
#   (optional) What auth system to use
#   Defaults to 'keystone'. Can other be 'noauth'
#
# [*auth_host*]
#   (optional) The keystone host
#   Defaults to localhost
#
# [*auth_protocol*]
#   (optional) The protocol used to access the auth host
#   Defaults to http.
#
# [*auth_port*]
#   (optional) The keystone auth port
#   Defaults to 35357
#
# [*auth_admin_prefix*]
#   (optional) The admin_prefix used to admin endpoint of the auth host
#   This allow admin auth URIs like http://auth_host:35357/keystone.
#   (where '/keystone' is the admin prefix)
#   Defaults to false for empty. If defined, should be a string with a leading '/' and no trailing '/'.
#
# [*auth_tenant*]
#   (optional) The tenant of the auth user
#   Defaults to services
#
# [*auth_user*]
#   (optional) The name of the auth user
#   Defaults to quantum
#
# [*auth_protocol*]
#   (optional) The protocol to connect to keystone
#   Defaults to http
#
class quantum::server (
  $package_ensure    = 'present',
  $enabled           = true,
  $auth_password     = false,
  $auth_type         = 'keystone',
  $auth_host         = 'localhost',
  $auth_port         = '35357',
  $auth_admin_prefix = false,
  $auth_tenant       = 'services',
  $auth_user         = 'quantum',
  $auth_protocol     = 'http',
  $log_file          = false,
  $log_dir           = '/var/log/quantum'
) {

  include quantum::params
  require keystone::python

  Quantum_config<||>     ~> Service['quantum-server']
  Quantum_api_config<||> ~> Service['quantum-server']

  if $log_file {
    quantum_config {
      'DEFAULT/log_file': value  => $log_file;
      'DEFAULT/log_dir':  ensure => absent;
    }
  } else {
    quantum_config {
      'DEFAULT/log_dir':  value  => $log_dir;
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if ($::quantum::params::server_package) {
    Package['quantum-server'] -> Quantum_api_config<||>
    Package['quantum-server'] -> Quantum_config<||>
    Package['quantum-server'] -> Service['quantum-server']
    package { 'quantum-server':
      name   => $::quantum::params::server_package,
      ensure => $package_ensure
    }
  } else {
    # Some platforms (RedHat) does not provide a quantum-server package.
    # The quantum api config file is provided by the quantum package.
    Package['quantum'] -> Quantum_api_config<||>
  }

  if ($auth_type == 'keystone') {

    if ($auth_password == false) {
      fail('$auth_password must be set when using keystone authentication.')
    } else {
      quantum_config {
        'keystone_authtoken/auth_host':         value => $auth_host;
        'keystone_authtoken/auth_port':         value => $auth_port;
        'keystone_authtoken/auth_protocol':     value => $auth_protocol;
        'keystone_authtoken/admin_tenant_name': value => $auth_tenant;
        'keystone_authtoken/admin_user':        value => $auth_user;
        'keystone_authtoken/admin_password':    value => $auth_password;
      }

      quantum_api_config {
        'filter:authtoken/auth_host':         value => $auth_host;
        'filter:authtoken/auth_port':         value => $auth_port;
        'filter:authtoken/auth_protocol':     value => $auth_protocol;
        'filter:authtoken/admin_tenant_name': value => $auth_tenant;
        'filter:authtoken/admin_user':        value => $auth_user;
        'filter:authtoken/admin_password':    value => $auth_password;
      }

      if $auth_admin_prefix {
        validate_re($auth_admin_prefix, '^(/.+[^/])?$')
        quantum_config {
          'keystone_authtoken/auth_admin_prefix': value => $auth_admin_prefix;
        }
        quantum_api_config {
          'filter:authtoken/auth_admin_prefix': value => $auth_admin_prefix;
        }
      } else {
        quantum_config {
          'keystone_authtoken/auth_admin_prefix': ensure => absent;
        }
        quantum_api_config {
          'filter:authtoken/auth_admin_prefix': ensure => absent;
        }
      }
    }

  }

  service { 'quantum-server':
    name       => $::quantum::params::server_service,
    ensure     => $service_ensure,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['quantum'],
  }
}
