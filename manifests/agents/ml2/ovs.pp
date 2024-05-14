#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: neutron::agents::ml2::ovs
#
# Setups OVS neutron agent when using ML2 plugin
#
# === Parameters
#
# [*package_ensure*]
#   (Optional) The state of the package
#   Defaults to 'present'
#
# [*enabled*]
#   (Optional) Whether or not to enable the OVS Agent
#   Defaults to true
#
# [*manage_service*]
#   (Optional) Whether to start/stop the service
#   Defaults to true
#
# [*bridge_uplinks*]
#   (Optional) List of interfaces to connect to the bridge when doing
#   bridge mapping.
#   Defaults to empty list
#
# [*bridge_mappings*]
#   (Optional) List of <physical_network>:<bridge>
#   Defaults to empty list
#
# [*ovsdb_timeout*]
#   (Optional) The timeout in seconds for OVSDB commands.
#   Defaults to $facts['os_service_default']
#
# [*of_listen_address*]
#   (Optional) Address to listen on for OpenFlow connections.
#   Defaults to $facts['os_service_default']
#
# [*of_listen_port*]
#   (Optional) Port to listen on for OpenFlow connections.
#   Defaults to $facts['os_service_default']
#
# [*of_connect_timeout*]
#   (Optional) Timeout in seconds to wait for the local switch
#   connecting to the controller.
#   Defaults to $facts['os_service_default']
#
# [*of_request_timeout*]
#   (Optional) Timeout in seconds to wait for a single OpenFlow request.
#   Defaults to $facts['os_service_default']
#
# [*of_inactivity_probe*]
#   (Optional) The inactivity_probe interval in second for the local switch
#   connection to the controller. A value of 0 disables inactivity probes.
#   Defaults to $facts['os_service_default']
#
# [*integration_bridge*]
#   (Optional) Integration bridge in OVS
#   Defaults to $facts['os_service_default']
#
# [*tunnel_types*]
#   (Optional) List of types of tunnels to use when utilizing tunnels,
#   either 'gre' or 'vxlan'.
#   Defaults to empty list
#
# [*local_ip*]
#   (Optional) Local IP address of VXLAN/GRE tunnel endpoints.
#   Required when enabling tunneling
#   Defaults to undef
#
# [*tunnel_bridge*]
#   (Optional) Bridge used to transport tunnels
#   Defaults to $facts['os_service_default']
#
# [*vxlan_udp_port*]
#   (Optional) The UDP port to use for VXLAN tunnels.
#   Defaults to $facts['os_service_default']
#
# [*polling_interval*]
#   (Optional) The number of seconds the agent will wait between
#   polling for local device changes.
#   Defaults to $facts['os_service_default']
#
# [*report_interval*]
#   (Optional) Set the agent report interval. By default the global report
#   interval in neutron.conf ([agent]/report_interval) is used. This parameter
#   can be used to override the reporting interval for the openvswitch-agent.
#   Defaults to $facts['os_service_default']
#
# [*rpc_response_max_timeout*]
#   (Optional) Maximum seconds to wait for a response from an RPC call
#   Defaults to: $facts['os_service_default']
#
# [*l2_population*]
#   (Optional) Extension to use alongside ml2 plugin's l2population
#   mechanism driver.
#   Defaults to $facts['os_service_default']
#
# [*arp_responder*]
#   (Optional) Enable or not the ARP responder.
#   Recommended when using l2 population mechanism driver.
#   Defaults to $facts['os_service_default']
#
# [*firewall_driver*]
#   (Optional) Firewall driver for realizing neutron security group function.
#   Defaults to 'iptables_hybrid'.
#
# [*enable_distributed_routing*]
#   (Optional) Set to True on L2 agents to enable support
#   for distributed virtual routing.
#   Defaults to $facts['os_service_default']
#
# [*drop_flows_on_start*]
#   (Optional) Set to True to drop all flows during agent start for a clean
#   flow tables resetting
#   Defaults to $facts['os_service_default']
#
# [*manage_vswitch*]
#   (Optional) This boolean is used to indicate if this class should manage the
#   vswitch software installation and the ovs bridges/ports from the
#   $bridge_mappings parameter. If manage_vswitch is set to true, then we will
#   require the vswitch::ovs and configure the ovs bridges/ports using the
#   mappings provided as part of the $bridge_mappings parameters.
#   Defaults to true
#
# [*extensions*]
#   (Optional) Extensions list to use
#   Defaults to $facts['os_service_default']
#
# [*int_peer_patch_port*]
#   (Optional) Peer patch port in integration bridge for tunnel bridge
#   Defaults to $facts['os_service_default']
#
# [*tun_peer_patch_port*]
#   (Optional) Peer patch port in tunnel bridge for integration bridge
#   Defaults to $facts['os_service_default']
#
# [*datapath_type*]
#   (Optional) Datapath type for ovs bridges
#   Defaults to $facts['os_service_default']
#
# [*vhostuser_socket_dir*]
#   (Optional) The vhost-user socket directory for OVS
#   Defaults to $facts['os_service_default']
#
# [*purge_config*]
#   (Optional) Whether to set only the specified config options
#   in the ovs config.
#   Defaults to false.
#
# [*enable_dpdk*]
#   (Optional) Enable or not DPDK with OVS
#   Defaults to false.
#
# [*enable_security_group*]
#   (Optional) Controls whether the agent supports security
#   groups or not.
#   Defaults to $facts['os_service_default']
#
# [*permitted_ethertypes*]
#   (Optional) List of additional ethernet types to be configured
#   on the firewall.
#   Defaults to $facts['os_service_default']
#
# [*minimize_polling*]
#   (Optional) Minimize polling by monitoring ovsdb for interface
#   changes. (boolean value)
#   Defaults to $facts['os_service_default']
#
# [*tunnel_csum*]
#   (Optional) Set or un-set the tunnel header checksum  on
#   outgoing IP packet carrying GRE/VXLAN tunnel.
#   Defaults to $facts['os_service_default']
#
# [*bridge_mac_table_size*]
#   (Optional) The maximum number of MAC addresses to learn on a bridge managed
#   by the Neutron OVS agent.
#   Defaults to $facts['os_service_default']
#
# [*igmp_snooping_enable*]
#   (Optional) Enable IGMP snooping for integration bridge. If this option is
#   set to True, support for Internet Group Management Protocol (IGMP) is
#   enabled in integration bridge.
#   Defaults to $facts['os_service_default']
#
# [*igmp_flood*]
#   (Optional) Multicast packets (except reports) are unconditionally forwarded
#   to the ports bridging a local network to a physical network.
#   Defaults to $facts['os_service_default']
#
# [*igmp_flood_reports*]
#   (Optional) Multicast reports are unconditionally forwarded to the ports
#   bridging a logical network to a physical network.
#   Defaults to $facts['os_service_default']
#
# [*igmp_flood_unregistered*]
#   (Optional) This option enables or disables flooding of unregistered
#   multicast packets to all ports. If False, the switch will send unregistered
#   multicast packets only to ports connected to multicast routers.
#   Defaults to $facts['os_service_default']
#
# [*resource_provider_bandwidths*]
#   (Optional) List of <bridge>:<egress_bw>:<ingress_bw>
#   Defaults to empty list
#
# [*resource_provider_hypervisors*]
#   (Optional) List of <bridge>:<hypervisor>
#   Defaults to empty list
#
# [*resource_provider_packet_processing_without_direction*]
#   (Optional) List of <hypervisor>:<packet_rate> tuples, defining the minimum
#   packet rate the OVS backend can guarantee in kilo (1000) packet per second.
#   Defaults to empty list
#
# [*resource_provider_packet_processing_with_direction*]
#   (Optional) Similar to resource_provider_packet_processing_without_direction
#   but used in case the OVS backend has hardware offload capabilities.
#   Defaults to empty list
#
# [*resource_provider_default_hypervisor*]
#   (Optional) The default hypervisor name used to locate the parent of
#   the resource provider.
#   Defaults to $facts['os_service_default']
#
# [*resource_provider_inventory_defaults*]
#   (Optional) Key:value pairs to specify defaults used while reporting packet
#   rate inventories,.
#   Defaults to empty hash
#
# [*resource_provider_packet_processing_inventory_defaults*]
#   (Optional) Key:value pairs to specify defaults used while reporting packet
#   rate inventories,.
#   Defaults to empty hash
#
# [*explicitly_egress_direct*]
#   (Optional) When set to True, the accepted egress unicast traffic will not
#   use action NORMAL. The accepted egress packets will be taken care of in the
#   final egress tables direct output flows for unicast traffic. (boolean value)
#   Defaults to $facts['os_service_default']
#
# [*network_log_rate_limit*]
#   (Optional) Maximum packets logging per second.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#   Minimum possible value is 100.
#
# [*network_log_burst_limit*]
#   (Optional) Maximum number of packets per rate_limit.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#   Minimum possible value is 25.
#
# [*network_log_local_output_log_base*]
#   (Optional) Output logfile path on agent side, default syslog file.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#
# [*openflow_processed_per_port*]
#   (Optional) If enabled, all OVS OpenFlow rules associated to a port will be
#   processed at once, in one single transaction.
#   Defaults to $facts['os_service_default'].
#
class neutron::agents::ml2::ovs (
  $package_ensure                       = 'present',
  Boolean $enabled                      = true,
  Boolean $manage_service               = true,
  $extensions                           = $facts['os_service_default'],
  $bridge_uplinks                       = [],
  $bridge_mappings                      = [],
  $ovsdb_timeout                        = $facts['os_service_default'],
  $of_listen_address                    = $facts['os_service_default'],
  $of_listen_port                       = $facts['os_service_default'],
  $of_connect_timeout                   = $facts['os_service_default'],
  $of_request_timeout                   = $facts['os_service_default'],
  $of_inactivity_probe                  = $facts['os_service_default'],
  $integration_bridge                   = $facts['os_service_default'],
  Array $tunnel_types                   = [],
  $local_ip                             = undef,
  $tunnel_bridge                        = $facts['os_service_default'],
  $vxlan_udp_port                       = $facts['os_service_default'],
  $polling_interval                     = $facts['os_service_default'],
  $report_interval                      = $facts['os_service_default'],
  $rpc_response_max_timeout             = $facts['os_service_default'],
  $l2_population                        = $facts['os_service_default'],
  $arp_responder                        = $facts['os_service_default'],
  $firewall_driver                      = 'iptables_hybrid',
  $enable_distributed_routing           = $facts['os_service_default'],
  $drop_flows_on_start                  = $facts['os_service_default'],
  Boolean $manage_vswitch               = true,
  $int_peer_patch_port                  = $facts['os_service_default'],
  $tun_peer_patch_port                  = $facts['os_service_default'],
  $datapath_type                        = $facts['os_service_default'],
  $vhostuser_socket_dir                 = $facts['os_service_default'],
  Boolean $purge_config                 = false,
  Boolean $enable_dpdk                  = false,
  $enable_security_group                = $facts['os_service_default'],
  $permitted_ethertypes                 = $facts['os_service_default'],
  $minimize_polling                     = $facts['os_service_default'],
  $tunnel_csum                          = $facts['os_service_default'],
  $bridge_mac_table_size                = $facts['os_service_default'],
  $igmp_snooping_enable                 = $facts['os_service_default'],
  $igmp_flood                           = $facts['os_service_default'],
  $igmp_flood_reports                   = $facts['os_service_default'],
  $igmp_flood_unregistered              = $facts['os_service_default'],
  $resource_provider_bandwidths         = [],
  $resource_provider_packet_processing_without_direction
                                        = [],
  $resource_provider_packet_processing_with_direction
                                        = [],
  $resource_provider_hypervisors        = [],
  $resource_provider_default_hypervisor = $facts['os_service_default'],
  $resource_provider_inventory_defaults = {},
  $resource_provider_packet_processing_inventory_defaults
                                        = {},
  $explicitly_egress_direct             = $facts['os_service_default'],
  $network_log_rate_limit               = $facts['os_service_default'],
  $network_log_burst_limit              = $facts['os_service_default'],
  $network_log_local_output_log_base    = $facts['os_service_default'],
  $openflow_processed_per_port          = $facts['os_service_default'],
) {

  include neutron::deps
  include neutron::params

  if $enable_dpdk and ! $manage_vswitch {
    fail('Enabling DPDK without manage vswitch does not have any effect')
  }

  if $enable_dpdk and is_service_default($datapath_type) {
    fail('Datapath type for ovs agent must be set when DPDK is enabled')
  }

  if $enable_dpdk and is_service_default($vhostuser_socket_dir) {
    fail('vhost user socket directory for ovs agent must be set when DPDK is enabled')
  }

  if $manage_vswitch {
    if $enable_dpdk {
      require vswitch::dpdk
    } else {
      require vswitch::ovs
    }
  }

  if size($tunnel_types) > 0 {
    $enable_tunneling = true
  } else {
    $enable_tunneling = false
  }

  if $enable_tunneling and ! $local_ip {
    fail('Local ip for ovs agent must be set when tunneling is enabled')
  }

  if ($enable_tunneling) and (!is_service_default($enable_distributed_routing)) and (!is_service_default($l2_population)) {
    if $enable_distributed_routing and ! $l2_population {
      fail('L2 population must be enabled when DVR and tunneling are enabled')
    }
  }

  resources { 'neutron_agent_ovs':
    purge => $purge_config,
  }

  if !empty($bridge_mappings) {
    # bridge_mappings are used to describe external networks that are
    # *directly* attached to this machine.
    # (This has nothing to do with VM-VM comms over neutron virtual networks.)
    # Typically, the network node - running L3 agent - will want one external
    # network (often this is on the control node) and the other nodes (all the
    # compute nodes) will want none at all.  The only other reason you will
    # want to add networks here is if you're using provider networks, in which
    # case you will name the network with bridge_mappings and add the server's
    # interfaces that are attached to that network with bridge_uplinks.
    # (The bridge names can be nearly anything, they just have to match between
    # mappings and uplinks; they're what the OVS switches will get named.)

    $bridge_mappings_real = $bridge_mappings ? {
      Hash    => join_keys_to_values($bridge_mappings, ':'),
      String  => $bridge_mappings.split(',').strip(),
      default => $bridge_mappings,
    }

    # Set config for bridges that we're going to create
    # The OVS neutron plugin will talk in terms of the networks in the bridge_mappings
    neutron_agent_ovs {
      'ovs/bridge_mappings': value => join(any2array($bridge_mappings_real), ',');
    }

    if ($manage_vswitch) {
      neutron::plugins::ovs::bridge{ $bridge_mappings_real:
        before => Service['neutron-ovs-agent-service'],
      }
      neutron::plugins::ovs::port{ $bridge_uplinks:
        before => Service['neutron-ovs-agent-service'],
      }
    }
  } else {
    if !empty($bridge_uplinks) {
      warning('The bridge_uplinks parameter is ignored because no bridge mapping is given.')
    }

    neutron_agent_ovs {
      'ovs/bridge_mappings': ensure => absent
    }
  }

  if ($resource_provider_bandwidths != []) {
    $resource_provider_bandwidths_real = join(any2array($resource_provider_bandwidths), ',')
  } else {
    $resource_provider_bandwidths_real = $facts['os_service_default']
  }

  if ($resource_provider_hypervisors != []){
    $resource_provider_hypervisors_real = join(any2array($resource_provider_hypervisors), ',')
  } else {
    $resource_provider_hypervisors_real = $facts['os_service_default']
  }

  if ($resource_provider_packet_processing_without_direction != []){
    $resource_provider_packet_processing_without_direction_real =
      join(any2array($resource_provider_packet_processing_without_direction), ',')
  } else {
    $resource_provider_packet_processing_without_direction_real = $facts['os_service_default']
  }

  if ($resource_provider_packet_processing_with_direction != []){
    $resource_provider_packet_processing_with_direction_real =
      join(any2array($resource_provider_packet_processing_with_direction), ',')
  } else {
    $resource_provider_packet_processing_with_direction_real = $facts['os_service_default']
  }

  if empty($resource_provider_inventory_defaults) {
    $resource_provider_inventory_defaults_real = $facts['os_service_default']
  } else {
    if ($resource_provider_inventory_defaults =~ Hash){
      $resource_provider_inventory_defaults_real =
        join(join_keys_to_values($resource_provider_inventory_defaults, ':'), ',')
    } else {
      $resource_provider_inventory_defaults_real =
        join(any2array($resource_provider_inventory_defaults), ',')
    }
  }

  if empty($resource_provider_packet_processing_inventory_defaults) {
    $resource_provider_packet_processing_inventory_defaults_real = $facts['os_service_default']
  } else {
    if ($resource_provider_packet_processing_inventory_defaults =~ Hash){
      $resource_provider_packet_processing_inventory_defaults_real =
        join(join_keys_to_values($resource_provider_packet_processing_inventory_defaults, ':'), ',')
    } else {
      $resource_provider_packet_processing_inventory_defaults_real =
        join(any2array($resource_provider_packet_processing_inventory_defaults), ',')
    }
  }

  neutron_agent_ovs {
    'ovs/resource_provider_bandwidths':
      value => $resource_provider_bandwidths_real;
    'ovs/resource_provider_hypervisors':
      value => $resource_provider_hypervisors_real;
    'ovs/resource_provider_packet_processing_without_direction':
      value => $resource_provider_packet_processing_without_direction_real;
    'ovs/resource_provider_packet_processing_with_direction':
      value => $resource_provider_packet_processing_with_direction_real;
    'ovs/resource_provider_default_hypervisor':
      value => $resource_provider_default_hypervisor;
    'ovs/resource_provider_inventory_defaults':
      value => $resource_provider_inventory_defaults_real;
    'ovs/resource_provider_packet_processing_inventory_defaults':
      value => $resource_provider_packet_processing_inventory_defaults_real;
  }

  neutron_agent_ovs {
    'agent/polling_interval':               value => $polling_interval;
    'agent/report_interval':                value => $report_interval;
    'DEFAULT/rpc_response_max_timeout':     value => $rpc_response_max_timeout;
    'agent/l2_population':                  value => $l2_population;
    'agent/arp_responder':                  value => $arp_responder;
    'agent/enable_distributed_routing':     value => $enable_distributed_routing;
    'agent/drop_flows_on_start':            value => $drop_flows_on_start;
    'agent/extensions':                     value => join(any2array($extensions), ',');
    'agent/minimize_polling':               value => $minimize_polling;
    'agent/tunnel_csum':                    value => $tunnel_csum;
    'agent/explicitly_egress_direct':       value => $explicitly_egress_direct;
    'ovs/ovsdb_timeout':                    value => $ovsdb_timeout;
    'ovs/of_listen_address':                value => $of_listen_address;
    'ovs/of_listen_port':                   value => $of_listen_port;
    'ovs/of_connect_timeout':               value => $of_connect_timeout;
    'ovs/of_request_timeout':               value => $of_request_timeout;
    'ovs/of_inactivity_probe':              value => $of_inactivity_probe;
    'ovs/integration_bridge':               value => $integration_bridge;
    'ovs/datapath_type':                    value => $datapath_type;
    'ovs/vhostuser_socket_dir':             value => $vhostuser_socket_dir;
    'securitygroup/enable_security_group':  value => $enable_security_group;
    'securitygroup/permitted_ethertypes':   value => join(any2array($permitted_ethertypes), ',');
    'ovs/bridge_mac_table_size':            value => $bridge_mac_table_size;
    'ovs/igmp_snooping_enable':             value => $igmp_snooping_enable;
    'ovs/igmp_flood':                       value => $igmp_flood;
    'ovs/igmp_flood_reports':               value => $igmp_flood_reports;
    'ovs/igmp_flood_unregistered':          value => $igmp_flood_unregistered;
    'network_log/rate_limit':               value => $network_log_rate_limit;
    'network_log/burst_limit':              value => $network_log_burst_limit;
    'network_log/local_output_log_base':    value => $network_log_local_output_log_base;
    'ovs/openflow_processed_per_port':      value => $openflow_processed_per_port;
  }

  if $firewall_driver {
    neutron_agent_ovs { 'securitygroup/firewall_driver': value => $firewall_driver }
  } else {
    neutron_agent_ovs { 'securitygroup/firewall_driver': ensure => absent }
  }

  if $enable_tunneling {
    neutron_agent_ovs {
      'ovs/tunnel_bridge':       value => $tunnel_bridge;
      'ovs/local_ip':            value => $local_ip;
      'ovs/int_peer_patch_port': value => $int_peer_patch_port;
      'ovs/tun_peer_patch_port': value => $tun_peer_patch_port;
      'agent/tunnel_types':      value => join($tunnel_types, ',');
    }

    if 'vxlan' in $tunnel_types {
      if ! is_service_default($vxlan_udp_port) {
        validate_vxlan_udp_port($vxlan_udp_port)
      }
      neutron_agent_ovs {
        'agent/vxlan_udp_port': value => $vxlan_udp_port;
      }
    } else {
      neutron_agent_ovs {
        'agent/vxlan_udp_port': ensure => absent;
      }
    }
  } else {
    neutron_agent_ovs {
      'ovs/tunnel_bridge':       ensure => absent;
      'ovs/local_ip':            ensure => absent;
      'ovs/int_peer_patch_port': ensure => absent;
      'ovs/tun_peer_patch_port': ensure => absent;
      'agent/tunnel_types':      ensure => absent;
      'agent/vxlan_udp_port':    ensure => absent;
    }
  }

  package { 'neutron-ovs-agent':
    ensure => $package_ensure,
    name   => $::neutron::params::ovs_agent_package,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { 'neutron-ovs-agent-service':
      ensure => $service_ensure,
      name   => $::neutron::params::ovs_agent_service,
      enable => $enabled,
      tag    => ['neutron-service'],
    }
    Neutron_agent_ovs<||> ~> Service['neutron-ovs-agent-service']

    if $::neutron::params::destroy_patch_ports_service {
      # NOTE(tkajinam): The service should not be started in a running system.
      #                 DO NOT define ensure so the service status is not
      #                 changed.
      service { 'neutron-destroy-patch-ports-service':
        name    => $::neutron::params::destroy_patch_ports_service,
        enable  => $enabled,
        require => Anchor['neutron::service::begin'],
        before  => Anchor['neutron::service::end']
      }
    }

    if $::neutron::params::ovs_cleanup_service {
      # NOTE(tkajinam): This service should not be restarted, because it can
      #                 cause disruption of network connectivity.
      service { 'ovs-cleanup-service':
        name    => $::neutron::params::ovs_cleanup_service,
        enable  => $enabled,
        require => Anchor['neutron::service::begin'],
        before  => Anchor['neutron::service::end']
      }
    }
  }
}
