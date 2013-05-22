# == Class: quantum::agents::l3
#
# Installs and configures the Quantum L3 service
#
# TODO: create ability to have multiple L3 services
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*debug*]
#   (optional) Print debug info in logs
#   Defaults to false
#
# [*external_network_bridge*]
#   (optional) The name of the external bridge
#   Defaults to br-ex
#
# [*use_namespaces*]
#   (optional) Enable overlapping IPs / network namespaces
#   Defaults to false
#
# [*interface_driver*]
#   (optional) Driver to interface with quantum
#   Defaults to OVSInterfaceDriver
#
# [*router_id*]
#   (optional) The ID of the external router in quantum
#   Defaults to blank
#
# [*gateway_external_network_id*]
#   (optional) The ID of the external network in quantum
#   Defaults to blank
#
# [*handle_internal_only_routers*]
#   (optional) L3 Agent will handle non-external routers
#   Defaults to true
#
# [*metadata_port*]
#   (optional) The port of the metadata server
#   Defaults to 9697
#
class quantum::agents::l3 (
  $package_ensure               = 'present',
  $enabled                      = true,
  $debug                        = false,
  $external_network_bridge      = 'br-ex',
  $use_namespaces               = true,
  $interface_driver             = 'quantum.agent.linux.interface.OVSInterfaceDriver',
  $router_id                    = undef,
  $gateway_external_network_id  = undef,
  $handle_internal_only_routers = true,
  $metadata_port                = '9697',
  $root_helper                  = 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf'
) {

  include quantum::params

  Quantum_config<||>          ~> Service['quantum-l3']
  Quantum_l3_agent_config<||> ~> Service['quantum-l3']

  quantum_l3_agent_config {
    'DEFAULT/debug':                        value => $debug;
    'DEFAULT/external_network_bridge':      value => $external_network_bridge;
    'DEFAULT/use_namespaces':               value => $use_namespaces;
    'DEFAULT/interface_driver':             value => $interface_driver;
    'DEFAULT/router_id':                    value => $router_id;
    'DEFAULT/gateway_external_network_id':  value => $gateway_external_network_id;
    'DEFAULT/handle_internal_only_routers': value => $handle_internal_only_routers;
    'DEFAULT/metadata_port':                value => $metadata_port;
    'DEFAULT/root_helper':                  value => $root_helper;
  }

  if $::quantum::params::l3_agent_package {
    Package['quantum-l3'] -> Quantum_l3_agent_config<||>
    package { 'quantum-l3':
      name    => $::quantum::params::l3_agent_package,
      ensure  => $package_ensure,
      require => Package['quantum'],
    }
  } else {
    # Some platforms (RedHat) does not provide a quantum L3 agent package.
    # The quantum L3 agent config file is provided by the quantum package.
    Package['quantum'] -> Quantum_l3_agent_config<||>
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-l3':
    name    => $::quantum::params::l3_agent_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }
}
