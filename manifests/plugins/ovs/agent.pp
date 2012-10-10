class quantum::plugins::ovs::agent (
  $controller = false
) inherits quantum::plugin::ovs {
  Package["quantum-plugin-ovs-agent"] -> Quantum_plugin_ovs<||>

  class {
    "vswitch":
      provider => ovs
  }

  vs_bridge {$integration_bridge:
    external_ids => "bridge-id=$ingration_bridge",
    ensure       => present
  }
  
  if $enable_tunneling {
    vs_bridge {$tunnel_bridge:
      external_ids => "bridge-id=$tunnel_bridge",
      ensure       => present
    }
  }

  quantum::plugins::ovs::bridge{$bridge_mappings:}
  quantum::plugins::ovs::port{$bridge_uplinks:}

  package { "quantum-plugin-ovs-agent":
    name    => $::quantum::params::ovs_agent_package,
    ensure  => $package_ensure,
    require => [Class['quantum'], Service["quantum-plugin-ovs-service"]]
  }

  if $enabled {
    $service_ensure = "running"
  } else {
    $service_ensure = "stopped"
  }

  service { 'quantum-plugin-ovs-service':
    name    => $::quantum::params::ovs_agent_service,
    enable  => $enable,
    ensure  => $service_ensure,
    require => [Package["quantum-plugin-ovs-agent"]]
  }
}
