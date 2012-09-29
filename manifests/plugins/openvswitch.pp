#
class quantum::plugins::openvswitch (
  $private_bridge       = 'br-int',
  $private_interface    = 'eth1',
  $public_bridge        = 'br-ext',
  $public_interface     = 'eth0',
  $openvswitch_settings = false,
  $controller           = true
) {

  include quantum::params

  # Open vSwitch stuff
  package { 'openvswitch':
    name   => $::quantum::params::ovs_package,
    ensure => present,
  }

  case $::osfamily {
    'Debian': {
      package { 'kernel-headers':
        name   => $::quantum::params::kernel_headers,
        ensure => present,
      }
      package { 'openvswitch-datapath-dkms':
        ensure => present,
        require => [Package['kernel-headers'], Package['openvswitch']],
      }
    }
  }

  service { 'ovsdb-server':
    name       => $::quantum::params::ovs_service,
    enable     => true,
    ensure     => running,
    hasstatus  => false,
    status     => 'pgrep ovsdb-server',
    require    => Package['openvswitch-datapath-dkms'],
  }

  if $controller {
    $package = $::quantum::params::ovs_package_server
  } else {
    $package = $::quantum::params::ovs_package_agent
  }

  package { 'quantum-plugin-openvswitch':
    name    => $package,
    ensure  => latest,
    require => [Class['quantum'], Service[$::quantum::params::ovs_service]],
  }

  File {
    require => Package['quantum-plugin-openvswitch'],
  }
  file { $::quantum::params::quantum_ovs_plugin_ini: }

  if $openvswitch_settings {
    multini($::quantum::params::quantum_ovs_plugin_ini, $openvswitch_settings)
  }

  Exec {
    path => ['/bin', '/usr/bin'],
  }

  exec { "ovs-vsctl add-br ${private_bridge}":
    unless  => "ovs-vsctl list-br | grep ${private_bridge}",
    require => [Package[$package], Service[$::quantum::params::ovs_service]],
  }

  exec { "ovs-vsctl br-set-external-id ${private_bridge} bridge-id ${private_bridge}":
    unless  => "ovs-vsctl br-get-external-id ${private_bridge} bridge-id | grep ${private_bridge}",
    require => Exec["ovs-vsctl add-br ${private_bridge}"],
  }

  exec { "ovs-vsctl add-port ${private_bridge} ${private_interface}":
    unless  => "ovs-vsctl list-ports ${private_bridge} | grep ${private_interface}",
    require => Exec["ovs-vsctl br-set-external-id ${private_bridge} bridge-id ${private_bridge}"],
  }

  exec { "ovs-vsctl add-br ${public_bridge}":
    unless  => "ovs-vsctl list-br | grep ${public_bridge}",
    require => Package[$package],
  }

  exec { "ovs-vsctl br-set-external-id ${public_bridge} bridge-id ${public_bridge}":
    unless  => "ovs-vsctl br-get-external-id ${public_bridge} bridge-id | grep ${public_bridge}",
    require => Exec["ovs-vsctl add-br ${public_bridge}"],
  }

  case $::osfamily {
    'Debian': {
      file { '/etc/init/quantum-agent.conf':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/quantum/quantum-agent.conf',
      }
    
      file { '/etc/init.d/quantum-agent':
        ensure  => link,
        target  => '/lib/init/upstart-job',
        require => File['/etc/init/quantum-agent.conf'],
      }
      $init_file = '/etc/init.d/quantum-agent'
    }
  }

  service { 'quantum-ovs-service-agent':
    name    => $::quantum::params::ovs_service_agent,
    enable  => true,
    ensure  => running,
    require => [Package[$package], Exec["ovs-vsctl add-port ${private_bridge} ${private_interface}"], File[$init_file]],
  }

  Ini_setting<| tag == $::quantum::params::quantum_ovs_plugin_ini_tag |> ~> Service['quantum-ovs-service-agent']

}
