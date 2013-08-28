# == Class: quantum::agents::metadata
#
# Setup and configure Quantum metadata agent.
#
# === Parameters
#
# [*auth_password*]
#   (required) The password for the administrative user.
#
# [*shared_secret*]
#   (required) Shared secret to validate proxies Quantum metadata requests.
#
# [*package_ensure*]
#   Ensure state of the package. Defaults to 'present'.
#
# [*enabled*]
#   State of the service. Defaults to true.
#
# [*debug*]
#   Debug. Defaults to false.
#
# [*auth_tenant*]
#   The administrative user's tenant name. Defaults to 'services'.
#
# [*auth_user*]
#   The administrative user name for OpenStack Networking.
#   Defaults to 'quantum'.
#
# [*auth_url*]
#   The URL used to validate tokens. Defaults to 'http://localhost:35357/v2.0'.
#
# [*auth_region*]
#   The authentication region. Defaults to 'RegionOne'.
#
# [*metadata_ip*]
#   The IP address of the metadata service. Defaults to '127.0.0.1'.
#
# [*metadata_port*]
#   The TCP port of the metadata service. Defaults to 8775.
#
class quantum::agents::metadata (
  $auth_password,
  $shared_secret,
  $package_ensure = 'present',
  $enabled        = true,
  $debug          = false,
  $auth_tenant    = 'services',
  $auth_user      = 'quantum',
  $auth_url       = 'http://localhost:35357/v2.0',
  $auth_region    = 'RegionOne',
  $metadata_ip    = '127.0.0.1',
  $metadata_port  = '8775'
  ) {

  include quantum::params

  Package['quantum'] -> Quantum_metadata_agent_config<||>
  Quantum_config<||> ~> Service['quantum-metadata']
  Quantum_metadata_agent_config<||> ~> Service['quantum-metadata']

  quantum_metadata_agent_config {
    'DEFAULT/debug':                          value => $debug;
    'DEFAULT/auth_url':                       value => $auth_url;
    'DEFAULT/auth_region':                    value => $auth_region;
    'DEFAULT/admin_tenant_name':              value => $auth_tenant;
    'DEFAULT/admin_user':                     value => $auth_user;
    'DEFAULT/admin_password':                 value => $auth_password;
    'DEFAULT/nova_metadata_ip':               value => $metadata_ip;
    'DEFAULT/nova_metadata_port':             value => $metadata_port;
    'DEFAULT/metadata_proxy_shared_secret':   value => $shared_secret;
  }

  if $::quantum::params::metadata_agent_package {
    Package['quantum-metadata'] -> Quantum_metadata_agent_config<||>
    Package['quantum-metadata'] -> Service['quantum-metadata']
    package { 'quantum-metadata':
      ensure  => $package_ensure,
      name    => $::quantum::params::metadata_agent_package,
      require => Package['quantum'],
    }
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-metadata':
    ensure  => $ensure,
    name    => $::quantum::params::metadata_agent_service,
    enable  => $enabled,
    require => Class['quantum'],
  }
}
