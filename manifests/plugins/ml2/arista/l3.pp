#
# Copyright (C) 2016 Matthew J. Black
#
# Author: Matthew J. Black <mjblack@gmail.com>
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
# == Class: neutron::plugins::ml2::arista::l3_arista
#
# === Parameters
#
# [*primary_l3_host*]
#   (required) The Arista EOS IP address.
#
# [*primary_l3_host_username*]
#   (required) The Arista EOS username.
#
# [*primary_l3_host_password*]
#   (required) The Arista EOS password.
#
# [*secondary_l3_host*]
#   (optional) The Arist EOS IP address for second switch MLAGed
#   with the first one. Only required if $mlag_config is set to true.
#   Defaults to $facts['os_service_default']
#
# [*mlag_config*]
#   (optional) Indicates that the switch is in MLAG mode.
#   Defaults to $facts['os_service_default']
#
# [*l3_sync_interval*]
#   (optional) Sync interval in seconds between l3 service plugin and
#   the EOS.
#   Defaults to $facts['os_service_default']
#
# [*conn_timeout*]
#   (optional) Connection timeout interval in seconds.
#   Defaults to $facts['os_service_default']
#
# [*use_vrf*]
#   (optional) If it should create a router in VRF.
#   Defaults to $facts['os_service_default']
#
class neutron::plugins::ml2::arista::l3(
  $primary_l3_host,
  $primary_l3_host_username,
  $primary_l3_host_password,
  $secondary_l3_host        = $facts['os_service_default'],
  $mlag_config              = $facts['os_service_default'],
  $l3_sync_interval         = $facts['os_service_default'],
  $conn_timeout             = $facts['os_service_default'],
  $use_vrf                  = $facts['os_service_default'],
) {

  include neutron::deps
  require neutron::plugins::ml2

  # TODO(tkajinam): Reconsider how we implement this. We probably should allow
  #                 more flexible values like 'on' supported by oslo.config.
  # if !is_service_default($mlag_config) {
  #   validate_legacy(Boolean, 'validate_bool', $mlag_config)
  #   if $mlag_config and is_service_default($secondary_l3_host) {
  #     fail('Must set secondary_l3_host when mlag_config is true.')
  #   }
  # }

  neutron_plugin_ml2 {
    'l3_arista/primary_l3_host'         : value => $primary_l3_host;
    'l3_arista/primary_l3_host_username': value => $primary_l3_host_username;
    'l3_arista/primary_l3_host_password': value => $primary_l3_host_password, secret => true;
    'l3_arista/secondary_l3_host'       : value => $secondary_l3_host;
    'l3_arista/mlag_config'             : value => $mlag_config;
    'l3_arista/l3_sync_interval'        : value => $l3_sync_interval;
    'l3_arista/conn_timeout'            : value => $conn_timeout;
    'l3_arista/use_vrf'                 : value => $use_vrf;
  }
}
