# == Class: neutron::agents:lbaas:
#
# Setups Neutron Load Balancing agent.
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
#   (optional) Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*device_driver*]
#   (optional) Defaults to 'neutron.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver'.
#
# [*use_namespaces*]
#   (optional) Allow overlapping IP (Must have kernel build with
#   CONFIG_NET_NS=y and iproute2 package that supports namespaces).
#   Defaults to true.
#
# [*user_group*]
#   (optional) The user group. Defaults to nogroup.
#
class neutron::agents::lbaas (
  $package_ensure   = present,
  $enabled          = true,
  $debug            = false,
  $interface_driver = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $device_driver    = 'neutron.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver',
  $use_namespaces   = true,
  $user_group       = 'nogroup',
) {

  include neutron::params

  Neutron_config<||>            ~> Service['neutron-lbaas-service']
  Neutron_lbaas_agent_config<||> ~> Service['neutron-lbaas-service']

  case $device_driver {
    /\.haproxy/: {
      Package['haproxy'] -> Package<| title == 'neutron-lbaas-agent' |>
      package { 'haproxy':
        ensure => present,
        name   => $::neutron::params::haproxy_package,
      }
    }
    default: {
      fail("Unsupported device_driver ${device_driver}")
    }
  }

  # The LBaaS agent loads both neutron.ini and its own file.
  # This only lists config specific to the agent.  neutron.ini supplies
  # the rest.
  neutron_lbaas_agent_config {
    'DEFAULT/debug':              value => $debug;
    'DEFAULT/interface_driver':   value => $interface_driver;
    'DEFAULT/device_driver':      value => $device_driver;
    'DEFAULT/use_namespaces':     value => $use_namespaces;
    'DEFAULT/user_group':         value => $user_group;
  }

  if $::neutron::params::lbaas_agent_package {
    Package['neutron']            -> Package['neutron-lbaas-agent']
    Package['neutron-lbaas-agent'] -> Neutron_config<||>
    Package['neutron-lbaas-agent'] -> Neutron_lbaas_agent_config<||>
    package { 'neutron-lbaas-agent':
      ensure  => $package_ensure,
      name    => $::neutron::params::lbaas_agent_package,
    }
  } else {
    # Some platforms (RedHat) do not provide a neutron LBaaS agent package.
    # The neutron LBaaS agent config file is provided by the neutron package.
    Package['neutron'] -> Neutron_lbaas_agent_config<||>
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'neutron-lbaas-service':
    ensure  => $ensure,
    name    => $::neutron::params::lbaas_agent_service,
    enable  => $enabled,
    require => Class['neutron'],
  }
}
