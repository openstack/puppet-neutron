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
#   Defaults to $::os_service_default
#
# [*http_retries*]
#   (optional) Number of novaclient/ironicclient retries on failed http calls.
#   Defaults to $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*password*]
#   (optional) Password for connection to nova in admin context.
#
# [*notify_nova_on_port_status_changes*]
#   (optional) Send notification to nova when port status is active.
#   Defaults to undef
#
# [*notify_nova_on_port_data_changes*]
#   (optional) Send notifications to nova when port data (fixed_ips/floatingips)
#   change so nova can update its cache.
#   Defaults to undef
#
# [*auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name
#   Defaults to undef
#
# [*username*]
#   (optional) Username for connection to nova in admin context
#   Defaults to undef
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to undef
#
# [*project_name*]
#   (optional) Nova project's name
#   Defaults to undef
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to undef
#
# [*auth_url*]
#   (optional) Authorization URL for connection to nova in admin context.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to undef
#
# [*region_name*]
#   (optional) Name of nova region to use. Useful if keystone manages more than
#   one region.
#   Defaults to undef
#
# [*endpoint_type*]
#   (optional) The type of nova endpoint to use when looking up in
#   the keystone catalog.
#   Defaults to undef
#
class neutron::server::notifications (
  $send_events_interval               = $::os_service_default,
  $http_retries                       = $::os_service_default,
  # DEPRECATED PARAMETERS
  $password                           = undef,
  $notify_nova_on_port_status_changes = undef,
  $notify_nova_on_port_data_changes   = undef,
  $auth_type                          = undef,
  $username                           = undef,
  $project_domain_name                = undef,
  $project_name                       = undef,
  $user_domain_name                   = undef,
  $auth_url                           = undef,
  $region_name                        = undef,
  $endpoint_type                      = undef,
) {

  include neutron::deps

  # TODO(tkajinam): Remove this when we cleanup deprecated parameters
  include neutron::server::notifications::nova

  neutron_config {
    'DEFAULT/send_events_interval':               value => $send_events_interval;
    'DEFAULT/http_retries':                       value => $http_retries;
  }
}
