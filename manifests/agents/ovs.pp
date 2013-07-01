# == Class: quantum::agents::ovs
#
# Setups OVS quantum agent.
#
# === Parameters
#
# [*firewall_driver*]
#   (optional) Firewall driver for realizing quantum security group function.
#   Defaults to 'quantum.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'.
#
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
  $firewall_driver      = 'quantum.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'
) {

  include quantum::params
  require vswitch::ovs

  if $enable_tunneling and ! $local_ip {
    fail('Local ip for ovs agent must be set when tunneling is enabled')
  }

  Quantum_config<||>     ~> Service['quantum-plugin-ovs-service']
  Quantum_plugin_ovs<||> ~> Service['quantum-plugin-ovs-service']

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
    quantum_plugin_ovs {
      'OVS/bridge_mappings': value => $br_map_str;
    }
    quantum::plugins::ovs::bridge{ $bridge_mappings:
      before => Service['quantum-plugin-ovs-service'],
    }
    quantum::plugins::ovs::port{ $bridge_uplinks:
      before => Service['quantum-plugin-ovs-service'],
    }
  }

  quantum_plugin_ovs {
    'AGENT/polling_interval': value => $polling_interval;
    'OVS/integration_bridge': value => $integration_bridge;
  }

  if ($firewall_driver) {
    quantum_plugin_ovs { 'SECURITYGROUP/firewall_driver':
      value => $firewall_driver
    }
  } else {
    quantum_plugin_ovs { 'SECURITYGROUP/firewall_driver': ensure => absent }
  }

  vs_bridge { $integration_bridge:
    ensure => present,
    before => Service['quantum-plugin-ovs-service'],
  }

  if $enable_tunneling {
    vs_bridge { $tunnel_bridge:
      ensure => present,
      before => Service['quantum-plugin-ovs-service'],
    }
    quantum_plugin_ovs {
      'OVS/enable_tunneling': value => true;
      'OVS/tunnel_bridge':    value => $tunnel_bridge;
      'OVS/local_ip':         value => $local_ip;
    }
  } else {
    quantum_plugin_ovs {
      'OVS/enable_tunneling': value  => false;
      'OVS/tunnel_bridge':    ensure => absent;
      'OVS/local_ip':         ensure => absent;
    }
  }


  if $::quantum::params::ovs_agent_package {
    Package['quantum-plugin-ovs-agent'] -> Quantum_plugin_ovs<||>
    package { 'quantum-plugin-ovs-agent':
      name    => $::quantum::params::ovs_agent_package,
      ensure  => $package_ensure,
    }
  } else {
    # Some platforms (RedHat) do not provide a separate
    # quantum plugin ovs agent package. The configuration file for
    # the ovs agent is provided by the quantum ovs plugin package.
    Package['quantum-plugin-ovs'] -> Quantum_plugin_ovs<||>
    Package['quantum-plugin-ovs'] -> Service['ovs-cleanup-service']
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { 'quantum-plugin-ovs-service':
    name    => $::quantum::params::ovs_agent_service,
    enable  => $enabled,
    ensure  => $service_ensure,
    require => Class['quantum'],
  }

  if $::quantum::params::ovs_cleanup_service {
    service {'ovs-cleanup-service':
      name   => $::quantum::params::ovs_cleanup_service,
      enable => $enabled,
      ensure => $service_ensure,
    }
  }
}
