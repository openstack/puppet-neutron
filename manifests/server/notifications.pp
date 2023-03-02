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
# == Class: neutron::server::notifications
#
# Configure Notification System Options
#
# === Parameters
#
# [*send_events_interval*]
#   (optional) Number of seconds between sending events to nova if there are
#   any events to send.
#   Defaults to $facts['os_service_default']
#
# [*http_retries*]
#   (optional) Number of novaclient/ironicclient retries on failed http calls.
#   Defaults to $facts['os_service_default']
#
class neutron::server::notifications (
  $send_events_interval               = $facts['os_service_default'],
  $http_retries                       = $facts['os_service_default'],
) {

  include neutron::deps

  neutron_config {
    'DEFAULT/send_events_interval':               value => $send_events_interval;
    'DEFAULT/http_retries':                       value => $http_retries;
  }
}
