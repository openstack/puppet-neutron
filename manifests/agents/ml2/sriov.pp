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
# == Class: neutron::agents::ml2::sriov
#
# Setups SR-IOV neutron agent when using ML2 plugin
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to 'present'
#
# [*enabled*]
#   (required) Whether or not to enable the OVS Agent
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*physical_device_mappings*]
#   (optional) Array of <physical_network>:<physical device>
#   All physical networks listed in network_vlan_ranges
#   on the server should have mappings to appropriate
#   interfaces on each agent.
#   Value should be of type array, Defaults to $facts['os_service_default']
#
# [*rpc_response_max_timeout*]
#   (Optional) Maximum seconds to wait for a response from an RPC call
#   Defaults to: $facts['os_service_default']
#
# [*polling_interval*]
#   (optional) The number of seconds the agent will wait between
#   polling for local device changes.
#   Defaults to 2
#
# [*report_interval*]
#   (optional) Set the agent report interval. By default the global report
#   interval in neutron.conf ([agent]/report_interval) is used. This parameter
#   can be used to override the reporting interval for the sriov-agent.
#   Defaults to $facts['os_service_default']
#
# [*exclude_devices*]
#   (optional) Array of <network_device>:<excluded_devices> mapping
#   network_device to the agent's node-specific list of virtual functions
#   that should not be used for virtual networking. excluded_devices is a
#   semicolon separated list of virtual functions to exclude from network_device.
#   The network_device in the mapping should appear in the physical_device_mappings list.
#   Value should be of type array, Defaults to $facts['os_service_default']
#
# [*extensions*]
#   (optional) Extensions list to use
#   Defaults to $facts['os_service_default']
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the sriov config.
#   Defaults to false.
#
# [*number_of_vfs*]
#   (optional) List of <physical_network>:<number_of_vfs> specifying the number
#   VFs to be exposed per physical interface.
#   For example, to configure two interface with number of VFs, specify
#   it as ["eth1:4", "eth2:10"]
#   Defaults to $facts['os_service_default'].
#
# [*resource_provider_bandwidths*]
#   (optional) List of <network_device>:<egress_bw>:<ingress_bw>
#   Defaults to empty list
#
# [*resource_provider_hypervisors*]
#   (optional) List of <bridge>:<hypervisor>
#   Defaults to empty list
#
# [*resource_provider_default_hypervisor*]
#   (optional) The default hypervisor name used to locate the parent of
#   the resource provider.
#   Defaults to $facts['os_service_default']
#
# [*resource_provider_inventory_defaults*]
#   (optional) Key:value pairs to specify defaults used while reporting packet
#   rate inventories,.
#   Defaults to empty hash
#
class neutron::agents::ml2::sriov (
  $package_ensure                       = 'present',
  Boolean $enabled                      = true,
  Boolean $manage_service               = true,
  $physical_device_mappings             = $facts['os_service_default'],
  $rpc_response_max_timeout             = $facts['os_service_default'],
  $polling_interval                     = 2,
  $report_interval                      = $facts['os_service_default'],
  $exclude_devices                      = $facts['os_service_default'],
  $extensions                           = $facts['os_service_default'],
  Boolean $purge_config                 = false,
  $number_of_vfs                        = $facts['os_service_default'],
  $resource_provider_bandwidths         = [],
  $resource_provider_hypervisors        = [],
  $resource_provider_default_hypervisor = $facts['os_service_default'],
  $resource_provider_inventory_defaults = {},
) {

  include neutron::deps
  include neutron::params

  resources { 'neutron_sriov_agent_config':
    purge => $purge_config,
  }

  neutron_sriov_agent_config {
    'sriov_nic/exclude_devices':          value => pick(join(any2array($exclude_devices), ','), $facts['os_service_default']);
    'sriov_nic/physical_device_mappings': value => pick(join(any2array($physical_device_mappings), ','), $facts['os_service_default']);
    'agent/extensions':                   value => join(any2array($extensions), ',');
    'DEFAULT/rpc_response_max_timeout':   value => $rpc_response_max_timeout;
    'agent/polling_interval':             value => $polling_interval;
    'agent/report_interval':              value => $report_interval;
    # As of now security groups are not supported for SR-IOV ports.
    # It is required to disable Firewall driver in the SR-IOV agent config.
    'securitygroup/firewall_driver':      value => 'noop';
  }

  if !is_service_default($number_of_vfs) and !empty($number_of_vfs) {
    neutron_agent_sriov_numvfs { $number_of_vfs: ensure => present }
  }

  package { 'neutron-sriov-nic-agent':
    ensure => $package_ensure,
    name   => $neutron::params::sriov_nic_agent_package,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-sriov-nic-agent-service':
      ensure => $service_ensure,
      name   => $neutron::params::sriov_nic_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
    Neutron_sriov_agent_config<||> ~> Service['neutron-sriov-nic-agent-service']
    Neutron_agent_sriov_numvfs<||> ~> Service['neutron-sriov-nic-agent-service']
  }

  if ($resource_provider_bandwidths != []) {
    $resource_provider_bandwidths_real = join(any2array($resource_provider_bandwidths), ',')
  } else {
    $resource_provider_bandwidths_real = $facts['os_service_default']
  }

  if ($resource_provider_hypervisors != []) {
    $resource_provider_hypervisors_real = join(any2array($resource_provider_hypervisors), ',')
  } else {
    $resource_provider_hypervisors_real = $facts['os_service_default']
  }

  if empty($resource_provider_inventory_defaults) {
    $resource_provider_inventory_defaults_real = $facts['os_service_default']
  } else {
    if ($resource_provider_inventory_defaults =~ Hash){
      $resource_provider_inventory_defaults_real = join(join_keys_to_values($resource_provider_inventory_defaults, ':'), ',')
    } else {
      $resource_provider_inventory_defaults_real = join(any2array($resource_provider_inventory_defaults), ',')
    }
  }

  neutron_sriov_agent_config {
    'sriov_nic/resource_provider_bandwidths':         value => $resource_provider_bandwidths_real;
    'sriov_nic/resource_provider_hypervisors':        value => $resource_provider_hypervisors_real;
    'sriov_nic/resource_provider_default_hypervisor': value => $resource_provider_default_hypervisor;
    'sriov_nic/resource_provider_inventory_defaults': value => $resource_provider_inventory_defaults_real;
  }

}
