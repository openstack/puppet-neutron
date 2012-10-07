class quantum::plugins::openvswitch (
  $private_bridge       = 'br-int',
  $private_interface    = 'eth0',
  $public_bridge        = 'br-virtual',
  $public_interface     = 'eth1',
  $plugin_settings      = false,
  $controller           = true
) {
  include "quantum::params"

  notice("Controller $controller")

  if !$controller {
    $package = $::quantum::params::ovs_package_agent
    $package_require = Service[$::quantum::params::ovs_service]
  } else {
    $package = $::quantum::params::ovs_package_server
    $package_require = [Class['quantum'], Service[$::quantum::params::ovs_service]]
  }

  class {
    "vswitch":
      provider => ovs
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

  package { "quantum-plugin-openvswitch":
    name    => $package,
    ensure  => latest,
    require => $package_require
  }

  File {
    require => Package['quantum-plugin-openvswitch'],
  }
  file { $::quantum::params::quantum_ovs_plugin_ini: }

  if $openvswitch_settings {
    multini($::quantum::params::quantum_ovs_plugin_ini, $openvswitch_settings)
  }

  service { 'quantum-ovs-service-agent':
    name    => $::quantum::params::ovs_service_agent,
    enable  => true,
    ensure  => running,
    require => [Package[$package]]
  }

  Ini_setting<| tag == $::quantum::params::quantum_ovs_plugin_ini_tag |> ~> Service['quantum-ovs-service-agent']
}
