# == Class: quantum::agents::linuxbridge
#
# Setups linuxbridge quantum agent.
#
# === Parameters
#
# [*physical_interface_mappings*]
#   (required) Comma-separated list of <physical_network>:<physical_interface>
#   tuples mapping physical network names to agent's node-specific physical
#   network interfaces.
#
# [*firewall_driver*]
#   (optional) Firewall driver for realizing quantum security group function.
#   Defaults to 'quantum.agent.linux.iptables_firewall.IptablesFirewallDriver'.
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enable*]
#   (optional) Enable state for service. Defaults to 'true'.
#
class quantum::agents::linuxbridge (
  $physical_interface_mappings,
  $firewall_driver = 'quantum.agent.linux.iptables_firewall.IptablesFirewallDriver',
  $package_ensure  = 'present',
  $enable          = true
) {

  include quantum::params

  Quantum_config<||>             ~> Service['quantum-plugin-linuxbridge-service']
  Quantum_plugin_linuxbridge<||> ~> Service<| title == 'quantum-plugin-linuxbridge-service' |>

  if $::quantum::params::linuxbridge_agent_package {
    Package['quantum'] -> Package['quantum-plugin-linuxbridge-agent']
    Package['quantum-plugin-linuxbridge-agent'] -> Quantum_plugin_linuxbridge<||>
    Package['quantum-plugin-linuxbridge-agent'] -> Service['quantum-plugin-linuxbridge-service']
    package { 'quantum-plugin-linuxbridge-agent':
      ensure => $package_ensure,
      name   => $::quantum::params::linuxbridge_agent_package,
    }
  } else {
    # Some platforms (RedHat) do not provide a separate quantum plugin
    # linuxbridge agent package. The configuration file for the linuxbridge
    # agent is provided by the quantum linuxbridge plugin package.
    Package['quantum-plugin-linuxbridge'] -> Quantum_plugin_linuxbridge<||>
  }

  if $enable {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  quantum_plugin_linuxbridge {
    'LINUX_BRIDGE/physical_interface_mappings': value => $physical_interface_mappings;
    'SECURITYGROUP/firewall_driver':            value => $firewall_driver;
  }

  service { 'quantum-plugin-linuxbridge-service':
    ensure  => $service_ensure,
    name    => $::quantum::params::linuxbridge_agent_service,
    enable  => $enable,
  }
}
