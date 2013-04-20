class quantum::agents::ovs (
  $package_ensure       = 'present',
  $enabled              = true,
  $bridge_uplinks       = [],
  $bridge_mappings      = [],
  $integration_bridge   = 'br-int',
  $enable_tunneling     = false,
  $local_ip             = false,
  $tunnel_bridge        = 'br-tun',
  $polling_interval     = 2,
  $root_helper          = 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf'
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

  if ($bridge_mappings != []) {
    # bridge_mappings are used to describe external networks that are
    # *directly* attached to this machine.
    # (This has nothing to do with VM-VM comms over quantum virtual networks.)
    # Typically, the network node - running L3 agent - will want one external
    # network (often this is on the control node) and the other nodes (all the
    # compute nodes) will want none at all.  The only other reason you will
    # want to add networks here is if you're using provider networks, in which
    # case you will name the network with bridge_mappings and add the server's
    # interfaces that are attached to that network with bridge_uplinks.
    # (The bridge names can be nearly anything, they just have to match between
    # mappings and uplinks; they're what the OVS switches will get named.)

    # Set config for bridges that we're going to create
    # The OVS quantum plugin will talk in terms of the networks in the bridge_mappings
    $br_map_str = join($bridge_mappings, ',')
    quantum_plugin_ovs { 'OVS/bridge_mappings': value => $br_map_str; }
    quantum::plugins::ovs::bridge{$bridge_mappings:
      require      => Service['quantum-plugin-ovs-service'],
    }
    quantum::plugins::ovs::port{$bridge_uplinks:
      require      => Service['quantum-plugin-ovs-service'],
    }
  }

  quantum_plugin_ovs {
    'AGENT/polling_interval':       value => $polling_interval;
    'AGENT/root_helper':            value => $root_helper;
    'OVS/integration_bridge':       value => $integration_bridge;
  }

  if ($enable_tunneling) {
    quantum_plugin_ovs {
      'OVS/enable_tunneling':   value => 'True';
      'OVS/tunnel_bridge':      value => $tunnel_bridge;
    }
  }

  Quantum_config<||> ~> Service['quantum-plugin-ovs-service']

  vs_bridge {$integration_bridge:
    ensure       => present,
    require      => Service['quantum-plugin-ovs-service'],
  }

  if $enable_tunneling {
    vs_bridge {$tunnel_bridge:
      ensure       => present,
      require      => Service['quantum-plugin-ovs-service'],
    }
    quantum_plugin_ovs {
      'OVS/local_ip': value => $local_ip;
    }
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

  # The agent reads this from a local copy of the plugin config, even if the plugin itself is not running here

  service { 'quantum-plugin-ovs-service':
    name    => $::quantum::params::ovs_agent_service,
    enable  => $enable,
    ensure  => $service_ensure,
    require => [Package['quantum-plugin-ovs-agent']]
  }
}
