#
class quantum::dhcp (
  $keystone_password,
  $dhcp_settings          = false,
  $keystone_enabled       = true,
  $keystone_tenant        = 'services',
  $keystone_user          = 'quantum',
  $keystone_auth_host     = 'localhost',
  $keystone_auth_port     = '35357',
  $keystone_auth_protocol = 'http',
  $package_ensure         = 'latest',
  $enabled                = true
) {

  include quantum::params

  package { 'quantum-dhcp':
    name    => $::quantum::params::dhcp_package,
    ensure  => $package_ensure,
    require => Class['quantum'],
  }

  File {
    ensure  => present,
    owner   => 'quantum',
    group   => 'quantum',
    mode    => '0644',
    require => Package[$::quantum::params::dhcp_package],
    notify  => Service[$::quantum::params::dhcp_service],
  }

  file { $::quantum::params::quantum_dhcp_agent_ini: }

  if $dhcp_settings {
    multini($::quantum::params::quantum_dhcp_agent_ini, $dhcp_settings)
  }

  if $keystone_enabled {
    $auth_url = "${keystone_auth_protocol}://${keystone_auth_host}:${keystone_auth_port}/v2.0"
    $keystone_settings = {
      'DEFAULT' => {
        'auth_url'          => $auth_url,
        'admin_tenant_name' => $keystone_tenant,
        'admin_user'        => $keystone_user,
        'admin_password'    => $keystone_password,
      }
    }
    multini($::quantum::params::quantum_dhcp_agent_ini, $keystone_settings)
  }


  # Hopefully only temporary
  file { '/etc/init/quantum-dhcp-agent.conf':
    source => 'puppet:///modules/quantum/quantum-dhcp-agent.conf',
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-dhcp':
    name    => $::quantum::params::dhcp_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => [Package[$::quantum::params::dhcp_package], Class['quantum']],
    subscribe => File[$::quantum::params::quantum_dhcp_agent_ini],
  }

  Ini_setting<| tag == $::quantum::params::quantum_dhcp_agent_ini_tag |> ~> Service['quantum-dhcp']
}
