#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
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
# neutron::plugins::ml2::type_driver used by neutron::plugins::ml2
#
#  === Parameters:
#
# [*flat_networks*]
#  (required) List of physical_network names with which flat networks can be created.
#  Use * to allow flat networks with arbitrary physical_network names.
#
# [*tunnel_id_ranges*]
#  (required) Comma-separated list of <tun_min>:<tun_max> tuples enumerating ranges
#  of GRE tunnel IDs that are available for tenant network allocation
#
# [*network_vlan_ranges*]
#  (required) List of <physical_network>:<vlan_min>:<vlan_max> or <physical_network>
#  specifying physical_network names usable for VLAN provider and tenant networks, as
#  well as ranges of VLAN tags on each available for allocation to tenant networks.
#
# [*vni_ranges*]
#  (required) Comma-separated list of <vni_min> tuples enumerating ranges of VXLAN VNI IDs
#  that are available for tenant network allocation.
#
# [*vxlan_group*]
#  (required) Multicast group for VXLAN. If unset, disables VXLAN multicast mode.
#
# [*max_header_size*]
#  (optional) Geneve encapsulation header size is dynamic, this value is used to calculate
#  the maximum MTU for the driver.
#
define neutron::plugins::ml2::type_driver (
  $flat_networks,
  $tunnel_id_ranges,
  $network_vlan_ranges,
  $vni_ranges,
  $vxlan_group,
  $max_header_size
) {
  include neutron::deps

  case $name {
    'flat': {
      neutron_plugin_ml2 {
        'ml2_type_flat/flat_networks': value => join(any2array($flat_networks), ',');
      }
    }
    'gre': {
      # tunnel_id_ranges is required in gre
      if ! $tunnel_id_ranges {
        fail('when gre is part of type_drivers, tunnel_id_ranges should be given.')
      }
      validate_tunnel_id_ranges($tunnel_id_ranges)

      neutron_plugin_ml2 {
        'ml2_type_gre/tunnel_id_ranges': value => join(any2array($tunnel_id_ranges), ',');
      }
    }
    'vlan': {
      # network_vlan_ranges is required in vlan
      if ! $network_vlan_ranges {
        fail('when vlan is part of type_drivers, network_vlan_ranges should be given.')
      }

      validate_network_vlan_ranges($network_vlan_ranges)

      neutron_plugin_ml2 {
        'ml2_type_vlan/network_vlan_ranges': value => join(any2array($network_vlan_ranges), ',');
      }
    }
    'vxlan': {
      # vni_ranges and vxlan_group are required in vxlan
      if (! $vni_ranges) or (! $vxlan_group) {
        fail('when vxlan is part of type_drivers, vni_ranges and vxlan_group should be given.')
      }
      # test multicast ip address (ipv4 else ipv6):
      case $vxlan_group {
        /^2[\d.]+$/: {
          case $vxlan_group {
            /^(22[4-9]|23[0-9])\.(\d+)\.(\d+)\.(\d+)$/: {}
            default: {}
          }
        }
        /^ff[\d.]+$/: {}
        default: {
          fail("${vxlan_group} is not valid for vxlan_group.")
        }
      }
      validate_vni_ranges($vni_ranges)

      neutron_plugin_ml2 {
        'ml2_type_vxlan/vxlan_group': value => $vxlan_group;
        'ml2_type_vxlan/vni_ranges':  value => join(any2array($vni_ranges), ',');
      }
    }
    'local': {
      warning('local type_driver is useful only for single-box, because it provides no connectivity between hosts')
    }
    'geneve': {
      # vni_ranges is required in geneve
      if (! $vni_ranges) {
        fail('when geneve is part of type_drivers, vni_ranges should be given.')
      }
      validate_vni_ranges($vni_ranges)
      neutron_plugin_ml2 {
        'ml2_type_geneve/max_header_size': value => $max_header_size;
        'ml2_type_geneve/vni_ranges':      value => join(any2array($vni_ranges),',');
      }
    }
    default: {
      # detect an invalid type_drivers value
      warning('type_driver unknown.')
    }
  }
}
