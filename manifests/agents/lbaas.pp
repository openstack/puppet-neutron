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
#   (optional) Defaults to 'neutron_lbaas.drivers.haproxy.namespace_driver.HaproxyNSDriver'.
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
# [*ovs_use_veth*]
#   (optional) Uses veth for an interface or not.
#   Defaults to $::os_service_default.
#
class neutron::agents::lbaas (
  $package_ensure         = present,
  $enabled                = true,
  $manage_service         = true,
  $debug                  = $::os_service_default,
  $interface_driver       = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $device_driver          = 'neutron_lbaas.drivers.haproxy.namespace_driver.HaproxyNSDriver',
  $ovs_use_veth           = $::os_service_default,
  $user_group             = $::neutron::params::nobody_user_group,
  $manage_haproxy_package = true,
  $purge_config           = false,
) {

  include ::neutron::deps
  include ::neutron::params

  case $device_driver {
    /\.haproxy/: {
      Package <| title == $::neutron::params::haproxy_package |> -> Package <| title == 'neutron-lbaasv2-agent' |>
      if $manage_haproxy_package {
        ensure_packages([$::neutron::params::haproxy_package])
      }
    }
    $::os_service_default: {}
    default: {
      fail("Unsupported device_driver ${device_driver}")
    }
  }

  resources { 'neutron_lbaas_agent_config':
    purge => $purge_config,
  }

  # The LBaaS agent loads both neutron.conf and its own file.
  # This only lists config specific to the agent.  neutron.conf supplies
  # the rest.
  neutron_lbaas_agent_config {
    'DEFAULT/debug':              value => $debug;
    'DEFAULT/interface_driver':   value => $interface_driver;
    'DEFAULT/device_driver':      value => $device_driver;
    'DEFAULT/ovs_use_veth':       value => $ovs_use_veth;
    'haproxy/user_group':         value => $user_group;
  }

  Package['neutron'] -> Package['neutron-lbaasv2-agent']
  ensure_resource( 'package', 'neutron-lbaasv2-agent', {
    ensure => $package_ensure,
    name   => $::neutron::params::lbaasv2_agent_package,
    tag    => ['openstack', 'neutron-package'],
  })

  if $manage_service {
    $service_ensure = 'running'
    } else {
    $service_ensure = 'stopped'
  }

  service { 'neutron-lbaasv2-service':
    ensure => $service_ensure,
    name   => $::neutron::params::lbaasv2_agent_service,
    enable => $enabled,
    tag    => 'neutron-service',
  }
}
