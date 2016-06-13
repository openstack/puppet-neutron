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
# == Class: neutron::services::lbaas::octavia
#
# Configure the Octavia LBaaS service provider
#
# === Parameters:
#
# [*base_url*]
#   (optional) The url endpoint for Octavia.
#   Defaults to 'https://127.0.0.1:9876'
#
# [*request_poll_interval*]
#   (optional) Interval in sections to poll octavia when
#   entity is created, updated, or deleted
#   Defaults to $::os_service_default
#
# [*request_poll_timeout*]
#   (optional) Time to stop polling octavia when status
#   of an entity does not change.
#   Defaults to $::os_service_default
#
# [*allocates_vip*]
#   (optional) Whether Octavia is responsible for allocating
#   the VIP.
#   Defaults to $::os_service_default
#

class neutron::services::lbaas::octavia(
  $base_url              = 'http://127.0.0.1:9876',
  $request_poll_interval = $::os_service_default,
  $request_poll_timeout  = $::os_service_default,
  $allocates_vip         = $::os_service_default
) {

  include ::neutron::deps

  neutron_config {
    'octavia/base_url':              value => $base_url;
    'octavia/request_poll_interval': value => $request_poll_interval;
    'octavia/request_poll_timeout':  value => $request_poll_timeout;
    'octavia/allocates_vip':         value => $allocates_vip;
  }
}
