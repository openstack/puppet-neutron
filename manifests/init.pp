#
class quantum (
  $keystone_password,
  $quantum_settings       = false,
  $keystone_enabled       = true,
  $keystone_tenant        = 'services',
  $keystone_user          = 'quantum',
  $keystone_auth_host     = 'localhost',
  $keystone_auth_port     = '35357',
  $keystone_auth_protocol = 'http',
  $package_ensure         = 'latest',
  $enabled                = true,
) {

  include quantum::params

  package { 'quantum':
    name   => $::quantum::params::package_name,
    ensure => $package_ensure,
  }

  package { 'python-cliff':
    name   => $::quantum::params::cliff_name,
    ensure => latest,
  }

  File {
    ensure  => present,
    owner   => 'quantum',
    group   => 'quantum',
    mode    => '0644',
    require => Package[$::quantum::params::package_name],
    notify  => Service[$::quantum::params::service_name],
  }

  file { $::quantum::params::quantum_conf: }
  file { $::quantum::params::quantum_paste_api_ini: }

  if $quantum_settings {
    multini($::quantum::params::quantum_conf, $quantum_settings)
  }

  if $keystone_enabled {
    multini($::quantum::params::quantum_conf, { 'DEFAULT' => { 'auth_strategy' => 'keystone' } })
    $keystone_settings = {
      'filter:authtoken' => {
        'auth_host'         => $keystone_auth_host,
        'auth_port'         => $keystone_auth_port,
        'auth_protocol'     => $keystone_auth_protocol,
        'admin_user'        => $keystone_user,
        'admin_password'    => $keystone_password,
        'admin_tenant_name' => $keystone_tenant
      }
    }
 
    multini($::quantum::params::quantum_paste_api_ini, $keystone_settings)
 
  }

  # Temporary
  file { '/etc/init/quantum-server.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/quantum/quantum-server.conf',
    before => Service[$::quantum::params::service_name],
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum':
    name    => $::quantum::params::service_name,
    enable  => $enabled,
    ensure  => $ensure,
    require => Package[$::quantum::params::package_name],
  }

  Ini_setting<| tag == $::quantum::params::quantum_conf_tag |> ~> Service['quantum']
  Ini_setting<| tag == $::quantum::params::quantum_paste_api_ini_tag |> ~> Service['quantum']

  # This is a hack. Most likely a bug in the Ubuntu package
  #file { '/usr/lib/python2.7/dist-packages/bin/nova-dhcpbridge':
  #  type   => link,
  #  target => '/usr/bin/nova-dhcpbridge',
  #}

}
