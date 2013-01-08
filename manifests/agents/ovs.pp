class quantum::agents::ovs (
  $package_ensure       = 'present',
  $enabled              = true,
  $bridge_uplinks       = ['br-virtual:eth1'],
  $bridge_mappings      = ['physnet1:br-virtual'],
  $integration_bridge   = 'br-int',
  $enable_tunneling     = false,
  $local_ip             = false,
  $tunnel_bridge        = 'br-tun'
) {

  include 'quantum::params'
  if $enable_tunneling and ! $local_ip {
    fail('Local ip for ovs agent must be set when tunneling is enabled')
  }

  include 'quantum::params'
  require 'vswitch::ovs'

  Package['quantum'] ->  Package['quantum-plugin-ovs-agent']
  Package['quantum-plugin-ovs-agent'] -> Quantum_plugin_ovs<||>

  # Reads both its own and the base Quantum config
  Quantum_plugin_ovs<||> -> Service['quantum-plugin-ovs-service']
  Quantum_config<||> ~> Service['quantum-plugin-ovs-service']

  # If this machine is running the quantum service, it must be restarted
  # if the plugin config changes (e.g. if new provider networks are added
  # they are not available until the quantum service is restarted)
  @service { "quantum-server":
    subscribe +> Quantum_plugin_ovs<||>,
  }

  vs_bridge {$integration_bridge:
    ensure       => present,
    require      => Service['quantum-plugin-ovs-service'],
  }

  if $enable_tunneling {
    vs_bridge {$tunnel_bridge:
      ensure       => present,
      require      => Service['quantum-plugin-ovs-service'],
    }
  }

  quantum::plugins::ovs::bridge{$bridge_mappings:
    require      => Service['quantum-plugin-ovs-service'],
  }
  quantum::plugins::ovs::port{$bridge_uplinks:
    require      => Service['quantum-plugin-ovs-service'],
  }

  package { 'quantum-plugin-ovs-agent':
    name    => $::quantum::params::ovs_agent_package,
    ensure  => $package_ensure,
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  quantum_plugin_ovs {
    'OVS/local_ip': value => $local_ip;
  }

  service { 'quantum-plugin-ovs-service':
    name    => $::quantum::params::ovs_agent_service,
    enable  => $enable,
    ensure  => $service_ensure,
    require => [Package['quantum-plugin-ovs-agent']]
  }
}
