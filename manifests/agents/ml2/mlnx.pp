#
# == Class: neutron::agents::ml2::mlnx
#
# Setups MLNX neutron agent when using ML2 plugin
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to 'present'
#
# [*enabled*]
#   (required) Whether or not to enable the MLNX Agent
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*manage_package*]
#   (optional) Whether to install the package
#   Defaults to true
#
# [*physical_interface_mappings*]
#   (optional) Array of <physical_network>:<physical device>
#   All physical networks listed in network_vlan_ranges
#   on the server should have mappings to appropriate
#   interfaces on each agent.
#   Value should be of type array, Defaults to $::os_service_default
#
# [*polling_interval*]
#   (optional) The number of seconds the agent will wait between
#   polling for local device changes.
#   Defaults to $::os_service_default
#
# [*multi_interface_driver_mappings*]
#   (optional) A per physnet interface driver mapping used by
#   multidriver interface driver to manage the virtual
#   interface per physnet. a virtual network e.g vxlan
#   will map to the 'nil' physnet.
#   Defaults to $::os_service_default
#
# [*ipoib_physical_interface*]
#   (optional) Name of the IPoIB root device to use with
#   ipoib interface driver.
#   Defaults to $::os_service_default
#
# [*enable_multi_interface_driver_cache_maintenance*]
#   (optional) Enable periodic job to perform maintenance to the
#   embedded network cache for multi interface driver.
#   Set to true if a multi interface driver instance will
#   be active for an extended amount of time.
#   Defaults to false
#
# DEPRECATED PARAMETERS
#
# [*dhcp_broadcast_reply*]
#   (optional) Use broadcast in DHCP replies
#   Defaults to undef
#
# [*interface_driver*]
#   (optional) The driver used to manage the virtual interface.
#   Defaults to undef
#
class neutron::agents::ml2::mlnx (
  $package_ensure             = 'present',
  $enabled                    = true,
  $manage_service             = true,
  $manage_package             = true,
  $physical_interface_mappings                     = $::os_service_default,
  $polling_interval                                = $::os_service_default,
  $multi_interface_driver_mappings                 = $::os_service_default,
  $ipoib_physical_interface                        = $::os_service_default,
  $enable_multi_interface_driver_cache_maintenance = false,
  # DEPRECATED PARAMETERS
  $dhcp_broadcast_reply                            = undef,
  $interface_driver                                = undef,
) {

  include neutron::deps
  include neutron::params

  $mlnx_agent_package = $::neutron::params::mlnx_agent_package
  $mlnx_agent_service = $::neutron::params::mlnx_agent_service
  $eswitchd_package   = $::neutron::params::eswitchd_package
  $eswitchd_service   = $::neutron::params::eswitchd_service

  neutron_mlnx_agent_config {
    'eswitch/physical_interface_mappings': value => pick(join(any2array($physical_interface_mappings), ','), $::os_service_default);
    'agent/polling_interval'             : value => $polling_interval;
  }

  eswitchd_config {
    'DAEMON/fabrics': value => pick(join(any2array($physical_interface_mappings), ','), $::os_service_default);
  }

  $mappings_array = pick(join(any2array($multi_interface_driver_mappings), ','), $::os_service_default);

  neutron_dhcp_agent_config {
    'DEFAULT/multi_interface_driver_mappings'                 : value => $mappings_array;
    'DEFAULT/ipoib_physical_interface'                        : value => $ipoib_physical_interface;
    'DEFAULT/enable_multi_interface_driver_cache_maintenance' : value => $enable_multi_interface_driver_cache_maintenance;
  }

  neutron_l3_agent_config {
    'DEFAULT/multi_interface_driver_mappings'                 : value => $mappings_array;
    'DEFAULT/ipoib_physical_interface'                        : value => $ipoib_physical_interface;
    'DEFAULT/enable_multi_interface_driver_cache_maintenance' : value => $enable_multi_interface_driver_cache_maintenance;
  }

  if $interface_driver {
    warning("The interface_driver parameter is deprecated. Use the same parameter of \
neutron::agents::dhcp and neutron::agents::l3.")
    # NOTE(tkajinam): ensure_resource is required to allow workaround for
    #                 bug 1987460
    ensure_resource('neutron_dhcp_agent_config', 'DEFAULT/interface_driver', {
      'value' => $interface_driver
    })
    ensure_resource('neutron_l3_agent_config', 'DEFAULT/interface_driver', {
      'value' => $interface_driver
    })
  }

  if $dhcp_broadcast_reply {
    warning("The dhcp_broadcast_reply parameter is deprecated. \
Use the neutron::agents::dhcp::dhcp_broadcast_reply parameter instead.")
    # NOTE(tkajinam): ensure_resource is required to allow workaround for
    #                 bug 1987460
    ensure_resource('neutron_dhcp_agent_config', 'DEFAULT/dhcp_broadcast_reply', {
      'value' => $dhcp_broadcast_reply
    })
  }

  if $manage_package {
    ensure_packages($mlnx_agent_package, {
      ensure => $package_ensure,
      tag    => ['openstack'],
    })

    # NOTE(tkajinam): CentOS/RHEL uses the same package for both agent and
    #                 plugin. This is required to avoid conflict with
    #                 neutron::plugins::ml2::mellanox
    Package<| title == $mlnx_agent_package |> { tag +> 'neutron-package' }

    # NOTE(tkajinam): Ubuntu/Debian requires a separate package for eswitchd
    #                 service.
    if $eswitchd_package {
      ensure_packages($eswitchd_package, {
        ensure => $package_ensure,
        tag    => ['openstack', 'neutron-package'],
      })
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { $mlnx_agent_service:
      ensure => $service_ensure,
      name   => $mlnx_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }

    service { $eswitchd_service:
      ensure => $service_ensure,
      name   => $eswitchd_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }
}
