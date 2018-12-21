#
# Copyright (C) 2018 Binero AB.
#
# Author: Tobias Urdin <tobias.urdin@binero.se>
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
# == Class: neutron::agents::bgp_dragent
#
# Install and configure neutron BGP dragent from Neutron Dynamic Routing.
#
# === Parameters:
#
# [*package_ensure*]
#   (Optional) The state of the package.
#   Defaults to 'present'
#
# [*enabled*]
#   (Optional) The state of the service.
#   Defaults to true
#
# [*manage_service*]
#   (Optional) Whether to start/stop the service.
#   Defaults to true
#
# [*bgp_speaker_driver*]
#   (Optional) The BGP speaker driver to use.
#   Defaults to 'neutron_dynamic_routing.services.bgp.agent.driver.os_ken.driver.OsKenBgpDriver'
#
# [*bgp_router_id*]
#   (Optional) The BGP router ID.
#   Defaults to $::ipaddress
#
# [*purge_config*]
#   (Optional) Whether to set only the specified config options in the BGP dragent config.
#   Defaults to false
#
class neutron::agents::bgp_dragent(
  $package_ensure     = 'present',
  $enabled            = true,
  $manage_service     = true,
  $bgp_speaker_driver = 'neutron_dynamic_routing.services.bgp.agent.driver.os_ken.driver.OsKenBgpDriver',
  $bgp_router_id      = $::ipaddress,
  $purge_config       = false,
) {

  include ::neutron::deps
  include ::neutron::params

  resources { 'neutron_bgp_dragent_config':
    purge => $purge_config,
  }

  neutron_bgp_dragent_config {
    'bgp/bgp_speaker_driver': value => $bgp_speaker_driver;
    'bgp/bgp_router_id':      value => $bgp_router_id;
  }

  if $::neutron::params::dynamic_routing_package {
    ensure_packages('neutron-dynamic-routing', {
      ensure => $package_ensure,
      name   => $::neutron::params::dynamic_routing_package,
      tag    => ['openstack', 'neutron-package'],
    })
  }

  if $::neutron::params::bgp_dragent_package {
    ensure_packages('neutron-bgp-dragent', {
      ensure => $package_ensure,
      name   => $::neutron::params::bgp_dragent_package,
      tag    => ['openstack', 'neutron-package'],
    })
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-bgp-dragent':
      ensure => $service_ensure,
      name   => $::neutron::params::bgp_dragent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }
}
