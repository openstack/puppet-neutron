class quantum::plugins::openvswitch (
  $private_bridge       = 'br-int',
  $private_interface    = 'eth0',
  $public_bridge        = 'br-ext',
  $public_interface     = 'eth1',
  $openvswitch_settings = false,
  $controller           = true
) {
  include "quantum::params"

  class {
    "vswitch":
      provider => ovs
  }

  if $controller {
    $package = $::quantum::params::ovs_package_server
  } else {
    $package = $::quantum::params::ovs_package_agent
  }

  package { 'quantum-plugin-openvswitch':
    name    => $package,
    ensure  => latest,
    require => Service[$::quantum::params::ovs_service],
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

  vs_bridge {$private_bridge:
    external_ids => "bridge-id=$private_bridge"
  }

  vs_port {$private_interface:
    bridge  => $private_bridge
  }

  vs_bridge {$public_bridge:
    external_ids => "bridge-id=$public_bridge"
  }

  vs_port {$public_interface:
    bridge => $public_bridge
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
    require => [Package[$package], File[$init_file]]
  }

  Ini_setting<| tag == $::quantum::params::quantum_ovs_plugin_ini_tag |> ~> Service['quantum-ovs-service-agent']

}
