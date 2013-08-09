class neutron::agents::metadata (
  $auth_password,
  $shared_secret,
  $package_ensure               = 'present',
  $enabled                      = true,
  $debug                        = false,
  $auth_tenant                  = 'services',
  $auth_user                    = 'neutron',
  $auth_url                     = 'http://localhost:35357/v2.0',
  $auth_region                  = 'RegionOne',
  $metadata_ip                  = '127.0.0.1',
  $metadata_port                = '8775'
  ) {

  include neutron::params

  Package['neutron'] -> Neutron_metadata_agent_config<||>
  Neutron_config<||> ~> Service['neutron-metadata']
  Neutron_metadata_agent_config<||> ~> Service['neutron-metadata']

  neutron_metadata_agent_config {
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

  if $::neutron::params::metadata_agent_package {
    Package['neutron-metadata'] -> Neutron_metadata_agent_config<||>
    Package['neutron-metadata'] -> Service['neutron-metadata']
    package { 'neutron-metadata':
      ensure  => $package_ensure,
      name    => $::neutron::params::metadata_agent_package,
      require => Package['neutron'],
    }
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'neutron-metadata':
    ensure  => $ensure,
    name    => $::neutron::params::metadata_agent_service,
    enable  => $enabled,
    require => Class['neutron'],
  }
}
