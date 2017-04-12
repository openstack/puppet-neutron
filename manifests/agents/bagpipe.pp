#
# Copyright (C) 2017 Red Hat Inc.
#
# Author: Ricardo Noriega <rnoriega@redhat.com>
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
# == Class: neutron::agents::bagpipe
#
# Installs and configures the Neutron Bagpipe driver for BGPVPN
#
# === Parameters
#
# [*my_as*]
#   (required) Private Autonomous System number
#   Defaults to $::os_service_default
#
# [*api_port*]
#   BGP component API port
#   Defaults to $::os_service_default
#
# [*dataplane_driver_ipvpn*]
#   IP VPN dataplane driver class
#   Default to ovs
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*enable_rtc*]
#   Enable Route Target Constraint
#   Defaults to $::os_service_default
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*mpls_interface*]
#   MPLS outgoing interface for Linux and OVS drivers
#   Defaults to $::os_service_default
#
# [*ovs_bridge*]
#   OVS bridge to use
#   Defaults to $::os_service_default
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*peers*]
#   List of peers' IPs to establish p2p connections
#   Defaults to $::os_service_default
#
# [*proxy_arp*]
#   For OVS driver control if VRF will reply ARP messages
#   Defaults to false
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the l2gateway config.
#   Default to false.
#
# [*local_address*]
#   (required) Local IP of the server to carry BGP traffic
#   Defaults to $::ipaddress
#
class neutron::agents::bagpipe (
  $my_as,
  $api_port                = $::os_service_default,
  $dataplane_driver_ipvpn  = 'ovs',
  $enabled                 = true,
  $enable_rtc              = $::os_service_default,
  $manage_service          = true,
  $mpls_interface          = $::os_service_default,
  $ovs_bridge              = $::os_service_default,
  $package_ensure          = 'present',
  $peers                   = $::os_service_default,
  $proxy_arp               = false,
  $purge_config            = false,
  $local_address           = $::ipaddress,
) {

  include ::neutron::deps
  include ::neutron::params

  resources { 'neutron_bgpvpn_bagpipe_config':
    purge => $purge_config,
  }

  neutron_bgpvpn_bagpipe_config {
    'api/port':                                value => $api_port;
    'bgp/local_address':                       value => $local_address;
    'bgp/peers':                               value => join(any2array($peers), ',');
    'bgp/my_as':                               value => $my_as;
    'bgp/enable_rtc':                          value => $enable_rtc;
    'dataplane_driver_ipvpn/dataplane_driver': value => $dataplane_driver_ipvpn;
    'dataplane_driver_ipvpn/ovs_bridge':       value => $ovs_bridge;
    'dataplane_driver_ipvpn/proxy_arp':        value => $proxy_arp;
    'dataplane_driver_ipvpn/mpls_interface':   value => $mpls_interface;
  }

  if $::neutron::params::bagpipe_bgp_package {
    package { 'openstack-bagpipe-bgp':
      ensure => $package_ensure,
      name   => $::neutron::params::bagpipe_bgp_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'bagpipe-bgp':
      ensure => $service_ensure,
      name   => $::neutron::params::bgpvpn_bagpipe_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }
}
