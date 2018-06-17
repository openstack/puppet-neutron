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
# [*password*]
#   (required) Password for connection to nova in admin context.
#
# [*notify_nova_on_port_status_changes*]
#   (optional) Send notification to nova when port status is active.
#   Defaults to true
#
# [*notify_nova_on_port_data_changes*]
#   (optional) Send notifications to nova when port data (fixed_ips/floatingips)
#   change so nova can update its cache.
#   Defaults to true
#
# [*send_events_interval*]
#   (optional) Number of seconds between sending events to nova if there are
#   any events to send.
#   Defaults to $::os_service_default
#
# [*auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name
#   Defaults to 'password'
#
# [*username*]
#   (optional) Username for connection to nova in admin context
#   Defaults to 'nova'
#
# [*tenant_id*]
#   (optional) The UUID of the admin nova tenant. If provided this takes
#   precedence over tenant_name.
#
# [*tenant_name*]
#   (optional) The name of the admin nova tenant
#   Defaults to 'services'
#
# [*project_domain_id*]
#   (optional) Nova project's domain ID
#   Defaults to 'default'
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) Nova project's name
#   Defaults to 'services'
#
# [*user_domain_id*]
#   (optional) User's domain ID for connection to nova in admin context
#   Defaults to 'default'
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*auth_url*]
#   (optional) Authorization URL for connection to nova in admin context.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://127.0.0.1:35357'
#
# [*region_name*]
#   (optional) Name of nova region to use. Useful if keystone manages more than
#   one region.
#   Defaults to $::os_service_default
#
# [*endpoint_type*]
#   (optional) The type of nova endpoint to use when looking up in
#   the keystone catalog.
#   Defaults to $::os_service_default
#
class neutron::server::notifications (
  $password,
  $notify_nova_on_port_status_changes = true,
  $notify_nova_on_port_data_changes   = true,
  $send_events_interval               = $::os_service_default,
  $auth_type                          = 'password',
  $username                           = 'nova',
  $tenant_id                          = $::os_service_default,
  $tenant_name                        = 'services',
  $project_domain_id                  = 'default',
  $project_domain_name                = 'Default',
  $project_name                       = 'services',
  $user_domain_id                     = 'default',
  $user_domain_name                   = 'Default',
  $auth_url                           = 'http://127.0.0.1:35357',
  $region_name                        = $::os_service_default,
  $endpoint_type                      = $::os_service_default,
) {

  include ::neutron::deps

  if is_service_default($tenant_id) and (! $tenant_name) {
    fail('You must provide either tenant_name or tenant_id.')
  }

  neutron_config {
    'nova/auth_url':            value => $auth_url;
    'nova/username':            value => $username;
    'nova/password':            value => $password, secret => true;
    'nova/project_domain_id':   value => $project_domain_id;
    'nova/project_domain_name': value => $project_domain_name;
    'nova/project_name':        value => $project_name;
    'nova/user_domain_id':      value => $user_domain_id;
    'nova/user_domain_name':    value => $user_domain_name;
    'nova/region_name':         value => $region_name;
    'nova/endpoint_type':       value => $endpoint_type;
    'nova/auth_type':           value => $auth_type;
  }
  if ! is_service_default ($tenant_id) {
    if $tenant_id {
      neutron_config {
        'nova/tenant_id': value => $tenant_id;
      }
    }
  } else {
    neutron_config {
      'nova/tenant_name': value => $tenant_name;
    }
  }

  neutron_config {
    'DEFAULT/notify_nova_on_port_status_changes': value => $notify_nova_on_port_status_changes;
    'DEFAULT/notify_nova_on_port_data_changes':   value => $notify_nova_on_port_data_changes;
    'DEFAULT/send_events_interval':               value => $send_events_interval;
  }
}
