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
# == Class: neutron::services::lbaas::haproxy
#
# Configure the haproxy LBaaS service provider
#
# === Parameters:
#
# [*interface_driver*]
#   (optional) The driver to manage the virtual interface
#   Defaults to $::os_service_default
#
# [*periodic_interval*]
#   (optional) Seconds between periodic task runs
#   Defaults to $::os_service_default
#
# [*loadbalancer_state_path*]
#   (optional) Location to store config and state files
#   Defaults to $::os_service_default
#
# [*user_group*]
#   (optional) The user/group to run haproxy.
#   Defaults to $::os_service_default
#
# [*send_gratuitous_arp*]
#   (optional) Send gratuitous arps to flush the arp cache
#   when VIP is deleted and re-added.
#   Defaults to $::os_service_default
#
# [*jinja_config_template*]
#   (optional) The template location to be used for haproxy.
#   Defaults to $::os_service_default
#
#

class neutron::services::lbaas::haproxy(
  $interface_driver        = $::os_service_default,
  $periodic_interval       = $::os_service_default,
  $loadbalancer_state_path = $::os_service_default,
  $user_group              = $::os_service_default,
  $send_gratuitous_arp     = $::os_service_default,
  $jinja_config_template   = $::os_service_default
) {

  include ::neutron::deps

  neutron_config {
    'haproxy/interface_driver':         value => $interface_driver;
    'haproxy/periodic_interval':        value => $periodic_interval;
    'haproxy/loadbalancer_state_path':  value => $loadbalancer_state_path;
    'haproxy/user_group':               value => $user_group;
    'haproxy/send_gratuitous_arp':      value => $send_gratuitous_arp;
    'haproxy/jinja_config_template':    value => $jinja_config_template;
  }
}
