# == Class: quantum::agents:lbaas:
#
# Setups Quantum Load Balancing agent.
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
# [*interface_driver*]
#   (optional) Defaults to 'quantum.agent.linux.interface.OVSInterfaceDriver'.
#
# [*device_driver*]
#   (optional) Defaults to 'quantum.plugins.services.agent_loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver'.
#
# [*use_namespaces*]
#   (optional) Allow overlapping IP (Must have kernel build with
#   CONFIG_NET_NS=y and iproute2 package that supports namespaces).
#   Defaults to true.
#
# [*user_group*]
#   (optional) The user group. Defaults to nogroup.
#
class quantum::agents::lbaas (
  $package_ensure   = present,
  $enabled          = true,
  $debug            = false,
  $interface_driver = 'quantum.agent.linux.interface.OVSInterfaceDriver',
  $device_driver    = 'quantum.plugins.services.agent_loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver',
  $use_namespaces   = true,
  $user_group       = 'nogroup',
) {

  include quantum::params

  Quantum_config<||>            ~> Service['quantum-lbaas-service']
  Quantum_lbaas_agent_config<||> ~> Service['quantum-lbaas-service']

  case $device_driver {
    /\.haproxy/: {
      Package['haproxy'] -> Package<| title == 'quantum-lbaas-agent' |>
      package { 'haproxy':
        name   => $::quantum::params::haproxy_package,
        ensure => present,
      }
    }
    default: {
      fail("Unsupported device_driver ${device_driver}")
    }
  }

  # The LBaaS agent loads both quantum.ini and its own file.
  # This only lists config specific to the agent.  quantum.ini supplies
  # the rest.
  quantum_lbaas_agent_config {
    'DEFAULT/debug':              value => $debug;
    'DEFAULT/interface_driver':   value => $interface_driver;
    'DEFAULT/device_driver':      value => $device_driver;
    'DEFAULT/use_namespaces':     value => $use_namespaces;
    'DEFAULT/user_group':         value => $user_group;
  }

  if $::quantum::params::lbaas_agent_package {
    Package['quantum']            -> Package['quantum-lbaas-agent']
    Package['quantum-lbaas-agent'] -> Quantum_config<||>
    Package['quantum-lbaas-agent'] -> Quantum_lbaas_agent_config<||>
    package { 'quantum-lbaas-agent':
      name    => $::quantum::params::lbaas_agent_package,
      ensure  => $package_ensure,
    }
  } else {
    # Some platforms (RedHat) do not provide a quantum LBaaS agent package.
    # The quantum LBaaS agent config file is provided by the quantum package.
    Package['quantum'] -> Quantum_lbaas_agent_config<||>
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-lbaas-service':
    name    => $::quantum::params::lbaas_agent_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }
}
