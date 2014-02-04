# == Class: neutron::server
#
# Setup and configure the neutron API endpoint
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
#   Defaults to /var/log/neutron
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
#   Defaults to neutron
#
# [*auth_protocol*]
#   (optional) The protocol to connect to keystone
#   Defaults to http
#
# [*auth_uri*]
#   (optional) Complete public Identity API endpoint.
#   Defaults to: $auth_protocol://$auth_host:5000/
#
# [*connection*]
#   (optional) Connection url for the neutron database.
#   Deprecates sql_connection
#   Defaults to: sqlite:////var/lib/neutron/ovs.sqlite
#
# [*max_retries*]
#   (optional) Database reconnection retry times.
#   Deprecates sql_max_retries
#   Defaults to: 10
#
# [*idle_timeout*]
#   (optional) Timeout before idle db connections are reaped.
#   Deprecates sql_idle_timeout
#   Defaults to: 3600
#
# [*retry_interval*]
#   (optional) Database reconnection interval in seconds.
#   Deprecates reconnect_interval
#   Defaults to: 10
#
# [*api_workers*]
#   (optional) Number of separate worker processes to spawn.
#   The default, 0, runs the worker thread in the current process.
#   Greater than 0 launches that number of child processes as workers.
#   The parent process manages them.
#   Defaults to: 0
#

class neutron::server (
  $package_ensure     = 'present',
  $enabled            = true,
  $auth_password      = false,
  $auth_type          = 'keystone',
  $auth_host          = 'localhost',
  $auth_port          = '35357',
  $auth_admin_prefix  = false,
  $auth_tenant        = 'services',
  $auth_user          = 'neutron',
  $auth_protocol      = 'http',
  $auth_uri           = false,
  $sql_connection     = 'sqlite:////var/lib/neutron/ovs.sqlite',
  $connection         = 'sqlite:////var/lib/neutron/ovs.sqlite',
  $max_retries        = '10',
  $sql_max_retries    = '10',
  $sql_idle_timeout   = '3600',
  $idle_timeout       = '3600',
  $reconnect_interval = '10',
  $retry_interval     = '10',
  $log_file           = false,
  $log_dir            = '/var/log/neutron',
  $api_workers        = '0'
) {

  include neutron::params
  require keystone::python

  Neutron_config<||>     ~> Service['neutron-server']
  Neutron_api_config<||> ~> Service['neutron-server']

  if $sql_connection {
    warning('sql_connection deprecated for connection')
    $connection_real = $sql_connection
  } else {
    $connection_real = $connection
  }

  if $sql_max_retries {
    warning('sql_max_retries deprecated for max_retries')
    $max_retries_real = $sql_max_retries
  } else {
    $max_retries_real = $max_retries
  }

  if $sql_idle_timeout {
    warning('sql_idle_timeout deprecated for idle_timeout')
    $idle_timeout_real = $sql_idle_timeout
  } else {
    $idle_timeout_real = $idle_timeout
  }

  if $reconnect_interval {
    warning('reconnect_interval deprecated for retry_interval')
    $retry_interval_real = $reconnect_interval
  } else {
    $retry_interval_real = $retry_interval
  }

  validate_re($connection_real, '(sqlite|mysql|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  case $connection_real {
    /mysql:\/\/\S+:\S+@\S+\/\S+/: {
      require 'mysql::python'
    }
    /postgresql:\/\/\S+:\S+@\S+\/\S+/: {
      $backend_package = 'python-psycopg2'
    }
    /sqlite:\/\//: {
      $backend_package = 'python-pysqlite2'
    }
    default: {
      fail("Invalid sql connection: ${connection_real}")
    }
  }

  neutron_config {
    'DEFAULT/api_workers':     value => $api_workers;
    'database/connection':     value => $connection_real;
    'database/idle_timeout':   value => $idle_timeout_real;
    'database/retry_interval': value => $retry_interval_real;
    'database/max_retries':    value => $max_retries_real;
  }

  if $log_file {
    neutron_config {
      'DEFAULT/log_file': value  => $log_file;
      'DEFAULT/log_dir':  ensure => absent;
    }
  } else {
    neutron_config {
      'DEFAULT/log_dir':  value  => $log_dir;
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if ($::neutron::params::server_package) {
    Package['neutron-server'] -> Neutron_api_config<||>
    Package['neutron-server'] -> Neutron_config<||>
    Package['neutron-server'] -> Service['neutron-server']
    package { 'neutron-server':
      ensure => $package_ensure,
      name   => $::neutron::params::server_package,
    }
  } else {
    # Some platforms (RedHat) does not provide a neutron-server package.
    # The neutron api config file is provided by the neutron package.
    Package['neutron'] -> Neutron_api_config<||>
  }

  if ($auth_type == 'keystone') {

    if ($auth_password == false) {
      fail('$auth_password must be set when using keystone authentication.')
    } else {
      neutron_config {
        'keystone_authtoken/auth_host':         value => $auth_host;
        'keystone_authtoken/auth_port':         value => $auth_port;
        'keystone_authtoken/auth_protocol':     value => $auth_protocol;
        'keystone_authtoken/admin_tenant_name': value => $auth_tenant;
        'keystone_authtoken/admin_user':        value => $auth_user;
        'keystone_authtoken/admin_password':    value => $auth_password;
      }

      neutron_api_config {
        'filter:authtoken/auth_host':         value => $auth_host;
        'filter:authtoken/auth_port':         value => $auth_port;
        'filter:authtoken/auth_protocol':     value => $auth_protocol;
        'filter:authtoken/admin_tenant_name': value => $auth_tenant;
        'filter:authtoken/admin_user':        value => $auth_user;
        'filter:authtoken/admin_password':    value => $auth_password;
      }

      if $auth_admin_prefix {
        validate_re($auth_admin_prefix, '^(/.+[^/])?$')
        neutron_config {
          'keystone_authtoken/auth_admin_prefix': value => $auth_admin_prefix;
        }
        neutron_api_config {
          'filter:authtoken/auth_admin_prefix': value => $auth_admin_prefix;
        }
      } else {
        neutron_config {
          'keystone_authtoken/auth_admin_prefix': ensure => absent;
        }
        neutron_api_config {
          'filter:authtoken/auth_admin_prefix': ensure => absent;
        }
      }

      if $auth_uri {
        neutron_config {
          'keystone_authtoken/auth_uri': value => $auth_uri;
        }
        neutron_api_config {
          'filter:authtoken/auth_uri': value => $auth_uri;
        }
      } else {
        neutron_config {
          'keystone_authtoken/auth_uri': value => "${auth_protocol}://${auth_host}:5000/";
        }
        neutron_api_config {
          'filter:authtoken/auth_uri': value => "${auth_protocol}://${auth_host}:5000/";
        }
      }

    }

  }

  service { 'neutron-server':
    ensure     => $service_ensure,
    name       => $::neutron::params::server_service,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['neutron'],
  }
}
