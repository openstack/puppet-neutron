class quantum::plugins::openvswitch (
  $private_bridge       = 'br-int',
  $private_interface    = 'eth0',
  $public_bridge        = 'br-ext',
  $public_interface     = 'eth1',
  $openvswitch_settings = false,
  $controller           = true
) {
  include "quantum::params"


  if $controller {
    $package = $::quantum::params::ovs_package_agent

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
  } else {
    $package = $::quantum::params::ovs_package_server
  }


  package { $package: }

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
