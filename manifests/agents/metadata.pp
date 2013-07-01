class quantum::agents::metadata (
  $auth_password,
  $shared_secret,
  $package_ensure               = 'present',
  $enabled                      = true,
  $debug                        = false,
  $auth_tenant                  = 'services',
  $auth_user                    = 'quantum',
  $auth_url                     = 'http://localhost:35357/v2.0',
  $auth_region                  = 'RegionOne',
  $metadata_ip                  = '127.0.0.1',
  $metadata_port                = '8775'
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
      name    => $::quantum::params::metadata_agent_package,
      ensure  => $package_ensure,
      require => Package['quantum'],
    }
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-metadata':
    name    => $::quantum::params::metadata_agent_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }
}
