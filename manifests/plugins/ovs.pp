class quantum::plugins::openvswitch (
  $bridge_uplinkgs      = ['br-virtual:eth1'],
  $bridge_mappings      = ['default:br-virtual'],
  $integration_bridge   = "br-int",
  $server               = true
) inherits quantum {
  include "quantum::params"

  if !$server {
    $package = $::quantum::params::ovs_agent_package
    $package_require = [Class['quantum'], Service[$::quantum::params::ovs_agent_service]]
  } else {
    $package = $::quantum::params::ovs_server_package
    $package_require = [Class['quantum'], Service[$::quantum::params::ovs_server_service]]
  }

  class {
    "vswitch":
      provider => ovs
  }

  vs_bridge {$integration_bridge:
    external_ids => "bridge-id=$ingration_bridge",
    ensure       => present
  }

  $::quantum::plugins::ovs::bridge{$bridge_mappings: }

  $::quantum::plugins::ovs::port{$bridge_uplinks: }

  package { "quantum-plugin-openvswitch":
    name    => $package,
    ensure  => latest,
    require => $package_require
  }

  quantum_plugin_ovs {
    bridge_mappings:    value     => $bridge_mappings,
    integration_bridge: value     => $integration_bridge
  }

  service { 'quantum-ovs-service-agent':
    name    => $::quantum::params::ovs_agent_service,
    enable  => true,
    ensure  => running,
    require => [Package[$package]]
  }
}
