# == Class: neutron::agents::ml2::linuxbridge
#
# Setups Linuxbridge Neutron agent for ML2 plugin.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Package ensure state.
#   Defaults to 'present'.
#
# [*enabled*]
#   (required) Whether or not to enable the agent.
#   Defaults to true.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*tunnel_types*]
#   (optional) List of types of tunnels to use when utilizing tunnels.
#   Supported tunnel types are: vxlan.
#   Defaults to an empty list.
#
# [*local_ip*]
#   (optional) Local IP address to use for VXLAN endpoints.
#   Required when enabling tunneling.
#   Defaults to false.
#
# [*vxlan_group*]
#   (optional) Multicast group for vxlan interface. If unset, disables VXLAN
#   multicast mode. Should be an Multicast IP (v4 or v6) address.
#   Default to '224.0.0.1'.
#
# [*vxlan_ttl*]
#   (optional) TTL for vxlan interface protocol packets..
#   Default to undef.
#
# [*vxlan_tos*]
#   (optional) TOS for vxlan interface protocol packets..
#   Defaults to undef.
#
# [*polling_interval*]
#   (optional) The number of seconds the agent will wait between
#   polling for local device changes.
#   Defaults to 2.
#
# [*l2_population*]
#   (optional) Extension to use alongside ml2 plugin's l2population
#   mechanism driver. It enables the plugin to populate VXLAN forwarding table.
#   Defaults to false.
#
# [*physical_interface_mappings*]
#   (optional) List of <physical_network>:<physical_interface>
#   tuples mapping physical network names to agent's node-specific physical
#   network interfaces. Defaults to empty list.
#
# [*firewall_driver*]
#   (optional) Firewall driver for realizing neutron security group function.
#   Defaults to 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the linuxbridge config.
#   Defaults to false.
#
class neutron::agents::ml2::linuxbridge (
  $package_ensure   = 'present',
  $enabled          = true,
  $manage_service   = true,
  $tunnel_types     = [],
  $local_ip         = false,
  $vxlan_group      = $::os_service_default,
  $vxlan_ttl        = $::os_service_default,
  $vxlan_tos        = $::os_service_default,
  $polling_interval = $::os_service_default,
  $l2_population    = $::os_service_default,
  $physical_interface_mappings = [],
  $firewall_driver  = 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver',
  $purge_config     = false,
) {

  validate_array($tunnel_types)
  validate_array($physical_interface_mappings)

  include ::neutron::deps
  include ::neutron::params

  resources { 'neutron_agent_linuxbridge':
    purge => $purge_config,
  }

  if ('vxlan' in $tunnel_types) {

    if ! $local_ip {
      fail('The local_ip parameter is required when vxlan tunneling is enabled')
    }

    neutron_agent_linuxbridge {
      'vxlan/vxlan_ttl':     value => $vxlan_ttl;
      'vxlan/vxlan_group':   value => $vxlan_group;
      'vxlan/vxlan_tos':     value => $vxlan_tos;
      'vxlan/enable_vxlan':  value => true;
      'vxlan/local_ip':      value => $local_ip;
      'vxlan/l2_population': value => $l2_population;
    }
  } else {
    neutron_agent_linuxbridge {
      'vxlan/enable_vxlan':  value  => false;
      'vxlan/local_ip':      ensure => absent;
    }
  }

  if size($tunnel_types) > 0 {
    neutron_agent_linuxbridge {
      'agent/tunnel_types': value => join($tunnel_types, ',');
    }
  } else {
    neutron_agent_linuxbridge {
      'agent/tunnel_types': ensure => absent;
    }
  }

  neutron_agent_linuxbridge {
    'agent/polling_interval':                   value => $polling_interval;
    'linux_bridge/physical_interface_mappings': value => join($physical_interface_mappings, ',');
  }

  if $firewall_driver {
    neutron_agent_linuxbridge { 'securitygroup/firewall_driver': value => $firewall_driver }
  } else {
    neutron_agent_linuxbridge { 'securitygroup/firewall_driver': ensure => absent }
  }

  if $::neutron::params::linuxbridge_agent_package {
    package { 'neutron-plugin-linuxbridge-agent':
      ensure => $package_ensure,
      name   => $::neutron::params::linuxbridge_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  } else {
    # Some platforms (RedHat) do not provide a separate
    # neutron plugin linuxbridge agent package.
    if ! defined(Package['neutron-plugin-linuxbridge-agent']) {
      package { 'neutron-plugin-linuxbridge-agent':
        ensure => $package_ensure,
        name   => $::neutron::params::linuxbridge_server_package,
        tag    => ['openstack', 'neutron-package'],
      }
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $::neutron::rpc_backend == 'neutron.openstack.common.rpc.impl_kombu' {
    $linuxbridge_agent_subscribe = [
      Neutron_config['oslo_messaging_rabbit/rabbit_hosts'],
      Neutron_config['DEFAULT/transport_url']
    ]
  } else {
    $linuxbridge_agent_subscribe = undef
  }

  service { 'neutron-plugin-linuxbridge-agent':
    ensure    => $service_ensure,
    name      => $::neutron::params::linuxbridge_agent_service,
    enable    => $enabled,
    tag       => 'neutron-service',
    subscribe => $linuxbridge_agent_subscribe,
  }
}
