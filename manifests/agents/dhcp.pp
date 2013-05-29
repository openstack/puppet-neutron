# == Class: quantum::agents::dhcp
#
# Setups Quantum DHCP agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enabled*]
#   (optional) Enable state for service. Defaults to 'true'.
#
# [*debug*]
#   (optional) Show debugging output in log. Defaults to false.
#
# [*state_path*]
#   (optional) Where to store dnsmasq state files. This directory must be
#   writable by the user executing the agent. Defaults to '/var/lib/quantum'.
#
# [*resync_interval*]
#   (optional) The DHCP agent will resync its state with Quantum to recover
#   from any transient notification or rpc errors. The interval is number of
#   seconds between attempts. Defaults to 30.
#
# [*interface_driver*]
#   (optional) Defaults to 'quantum.agent.linux.interface.OVSInterfaceDriver'.
#
# [*dhcp_driver*]
#   (optional) Defaults to 'quantum.agent.linux.dhcp.Dnsmasq'.
#
# [*use_namespaces*]
#   (optional) Allow overlapping IP (Must have kernel build with
#   CONFIG_NET_NS=y and iproute2 package that supports namespaces).
#   Defaults to true.
#
class quantum::agents::dhcp (
  $package_ensure   = present,
  $enabled          = true,
  $debug            = false,
  $state_path       = '/var/lib/quantum',
  $resync_interval  = 30,
  $interface_driver = 'quantum.agent.linux.interface.OVSInterfaceDriver',
  $dhcp_driver      = 'quantum.agent.linux.dhcp.Dnsmasq',
  $use_namespaces   = true
) {

  include quantum::params

  Quantum_config<||>            ~> Service['quantum-dhcp-service']
  Quantum_dhcp_agent_config<||> ~> Service['quantum-dhcp-service']

  case $dhcp_driver {
    /\.Dnsmasq/: {
      Package['dnsmasq'] -> Package<| title == 'quantum-dhcp-agent' |>
      package { 'dnsmasq':
        name   => $::quantum::params::dnsmasq_packages,
        ensure => present,
      }
    }
    default: {
      fail("Unsupported dhcp_driver ${dhcp_driver}")
    }
  }

  # The DHCP agent loads both quantum.ini and its own file.
  # This only lists config specific to the agent.  quantum.ini supplies
  # the rest.
  quantum_dhcp_agent_config {
    'DEFAULT/debug':              value => $debug;
    'DEFAULT/state_path':         value => $state_path;
    'DEFAULT/resync_interval':    value => $resync_interval;
    'DEFAULT/interface_driver':   value => $interface_driver;
    'DEFAULT/dhcp_driver':        value => $dhcp_driver;
    'DEFAULT/use_namespaces':     value => $use_namespaces;
  }

  if $::quantum::params::dhcp_agent_package {
    Package['quantum']            -> Package['quantum-dhcp-agent']
    Package['quantum-dhcp-agent'] -> Quantum_config<||>
    Package['quantum-dhcp-agent'] -> Quantum_dhcp_agent_config<||>
    package { 'quantum-dhcp-agent':
      name    => $::quantum::params::dhcp_agent_package,
      ensure  => $package_ensure,
    }
  } else {
    # Some platforms (RedHat) do not provide a quantum DHCP agent package.
    # The quantum DHCP agent config file is provided by the quantum package.
    Package['quantum'] -> Quantum_dhcp_agent_config<||>
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-dhcp-service':
    name    => $::quantum::params::dhcp_agent_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }
}
