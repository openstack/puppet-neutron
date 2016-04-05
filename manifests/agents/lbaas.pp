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
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   (optional) Show debugging output in log. Defaults to $::os_service_default.
#
# [*interface_driver*]
#   (optional) Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*device_driver*]
#   (optional) Defaults to 'neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver'.
#
# [*user_group*]
#   (optional) The user group.
#   Defaults to $::neutron::params::nobody_user_group
#
# [*manage_haproxy_package*]
#   (optional) Whether to manage the haproxy package.
#   Disable this if you are using the puppetlabs-haproxy module
#   Defaults to true
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the lbaas config.
#   Defaults to false.
#
# [*enable_v1*]
#   (optional) Whether to use lbaas v1 agent or not.
#   Defaults to true
#
# [*enable_v2*]
#   (optional) Whether to use lbaas v2 agent or not.
#   Defaults to false
#
class neutron::agents::lbaas (
  $package_ensure         = present,
  $enabled                = true,
  $manage_service         = true,
  $debug                  = $::os_service_default,
  $interface_driver       = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $device_driver          = 'neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver',
  $user_group             = $::neutron::params::nobody_user_group,
  $manage_haproxy_package = true,
  $purge_config           = false,
  $enable_v1              = true,
  $enable_v2              = false,
) {

  include ::neutron::params

  Neutron_config<||>             ~> Service['neutron-lbaas-service']
  Neutron_lbaas_agent_config<||> ~> Service['neutron-lbaas-service']

  if $enable_v1 and $enable_v2 {
    fail('neutron agents LBaaS enable_v1 and enable_v2 parameters cannot both be true')
  }

  case $device_driver {
    /\.haproxy/: {
      Package <| title == $::neutron::params::haproxy_package |> -> Package <| title == 'neutron-lbaas-agent' |>
      if $manage_haproxy_package {
        ensure_packages([$::neutron::params::haproxy_package])
      }
    }
    default: {
      fail("Unsupported device_driver ${device_driver}")
    }
  }

  resources { 'neutron_lbaas_agent_config':
    purge => $purge_config,
  }

  # The LBaaS agent loads both neutron.ini and its own file.
  # This only lists config specific to the agent.  neutron.ini supplies
  # the rest.
  neutron_lbaas_agent_config {
    'DEFAULT/debug':              value => $debug;
    'DEFAULT/interface_driver':   value => $interface_driver;
    'DEFAULT/device_driver':      value => $device_driver;
    'haproxy/user_group':         value => $user_group;
  }

  Package['neutron'] -> Package['neutron-lbaas-agent']
  ensure_resource( 'package', 'neutron-lbaas-agent', {
    ensure => $package_ensure,
    name   => $::neutron::params::lbaas_agent_package,
    tag    => ['openstack', 'neutron-package'],
  })
  if $::osfamily == 'Debian' {
    ensure_packages(['neutron-lbaasv2-package'], {
      ensure => $package_ensure,
      name   => $::neutron::params::lbaasv2_agent_package,
      tag    => ['openstack', 'neutron-package'],
    })
    Package['neutron'] -> Package['neutron-lbaasv2-package']
  }
  if $manage_service {
    if $enable_v1 {
      $service_v1_ensure = 'running'
      $service_v2_ensure = 'stopped'
    } elsif $enable_v2 {
      $service_v1_ensure = 'stopped'
      $service_v2_ensure = 'running'
    } else {
      $service_v1_ensure = 'stopped'
      $service_v2_ensure = 'stopped'
    }
    Package['neutron'] ~> Service['neutron-lbaas-service']
    Package['neutron-lbaas-agent'] ~> Service['neutron-lbaas-service']
  }

  service { 'neutron-lbaas-service':
    ensure  => $service_v1_ensure,
    name    => $::neutron::params::lbaas_agent_service,
    enable  => $enable_v1,
    require => Class['neutron'],
    tag     => 'neutron-service',
  }

  service { 'neutron-lbaasv2-service':
    ensure  => $service_v2_ensure,
    name    => $::neutron::params::lbaasv2_agent_service,
    enable  => $enable_v2,
    require => Class['neutron'],
    tag     => 'neutron-service',
  }
}
