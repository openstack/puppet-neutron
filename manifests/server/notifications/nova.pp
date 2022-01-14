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
# == Class: neutron::server::notifications::nova
#
# Configure notifications to nova
#
# === Parameters
#
# [*password*]
#   (required) Password for connection to nova in admin context.
#
# [*notify_nova_on_port_status_changes*]
#   (optional) Send notification to nova when port status is active.
#   Defaults to $::os_service_default
#
# [*notify_nova_on_port_data_changes*]
#   (optional) Send notifications to nova when port data (fixed_ips/floatingips)
#   change so nova can update its cache.
#   Defaults to $::os_service_default
#
# [*auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name
#   Defaults to 'password'
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*username*]
#   (optional) Username for connection to nova in admin context
#   Defaults to 'nova'
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) Nova project's name
#   Defaults to 'services'
#
# [*system_scope*]
#   (Optional) Scope for system operations
#   Defaults to $::os_service_default
#
# [*auth_url*]
#   (optional) Authorization URL for connection to nova in admin context.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://127.0.0.1:5000'
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
# DEPRECATED PARAMETERS
#
# [*live_migration_events*]
#   (optional) When this option is enabled, during the live migration, the OVS
#   agent will only send the "vif-plugged-event" when the destination host
#   interface is bound.
#   Defaults to $::os_service_default
#
class neutron::server::notifications::nova (
  $password,
  $notify_nova_on_port_status_changes = $::os_service_default,
  $notify_nova_on_port_data_changes   = $::os_service_default,
  $auth_type                          = 'password',
  $user_domain_name                   = 'Default',
  $username                           = 'nova',
  $project_domain_name                = 'Default',
  $project_name                       = 'services',
  $system_scope                       = $::os_service_default,
  $auth_url                           = 'http://127.0.0.1:5000',
  $region_name                        = $::os_service_default,
  $endpoint_type                      = $::os_service_default,
  # DEPRECATED PARAMETERS
  $live_migration_events              = undef,
) {

  include neutron::deps

  if $live_migration_events != undef {
    warning('The live_migration_events parameter is deprecated \
and will be removed in a future release')
  }

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $::os_service_default
    $project_domain_name_real = $::os_service_default
  }

  neutron_config {
    'nova/auth_type':           value => $auth_type;
    'nova/user_domain_name':    value => $user_domain_name;
    'nova/username':            value => $username;
    'nova/password':            value => $password, secret => true;
    'nova/project_domain_name': value => $project_domain_name_real;
    'nova/project_name':        value => $project_name_real;
    'nova/system_scope':        value => $system_scope;
    'nova/auth_url':            value => $auth_url;
    'nova/region_name':         value => $region_name;
    'nova/endpoint_type':       value => $endpoint_type;
  }

  neutron_config {
    'nova/live_migration_events':                 value => pick($live_migration_events, $::os_service_default);
    'DEFAULT/notify_nova_on_port_status_changes': value => $notify_nova_on_port_status_changes;
    'DEFAULT/notify_nova_on_port_data_changes':   value => $notify_nova_on_port_data_changes;
  }
}
