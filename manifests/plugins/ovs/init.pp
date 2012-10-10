class quantum::plugins::ovs (
  $bridge_uplinks       = ['br-virtual:eth1'],
  $bridge_mappings      = ['default:br-virtual'],
  $tenant_network_type  = "vlan",

  $network_vlan_ranges  = "default:1000:2000",
  $integration_bridge   = "br-int",

  $enable_tunneling     = "True",
  $tunnel_bridge        = "br-tun",
  $tunnel_id_ranges     = "1:1000",
  $local_ip             = "10.0.0.1",

  $controller           = true
) inherits quantum {
  Package["quantum-plugin-ovs"] -> Quantum_plugin_ovs<||>

  $package_require = [Class['quantum']]

  if $controller {
    Quantum_config<||> ~> Service["quantum-server"]
    Quantum_plugin_ovs<||> ~> Service["quantum-server"]

    $package_require += Service[$::quantum::params::server_service]
  }

  package { "quantum-plugin-ovs":
    name    => $::quantum::params::ovs_server_package,
    ensure  => $package_ensure,
    require => $package_require
  }

  $br_map_str = join($bridge_mappings, ",")
  quantum_plugin_ovs {
    "OVS/integration_bridge":   value => $integration_bridge;
    "OVS/network_vlan_ranges":  value => $network_vlan_ranges;
    "OVS/tenant_network_type":  value => $tenant_network_type;
    "OVS/bridge_mappings":      value => $br_map_str;
  }

  if ($tenant_network_type == "gre") and ($enable_tunneling) {
    quantum_plugin_ovs {
      "OVS/enable_tunneling":   value => $enable_tunneling;
      "OVS/tunnel_bridge":      value => $tunnel_bridge;
      "OVS/tunnel_id_ranges":   value => $tunnel_id_ranges;
      "OVS/local_ip":           value => $local_ip;
    }
  }
}
