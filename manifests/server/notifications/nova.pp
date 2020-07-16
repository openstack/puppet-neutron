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
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
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
class neutron::server::notifications::nova (
  $password                           = undef,
  $notify_nova_on_port_status_changes = $::os_service_default,
  $notify_nova_on_port_data_changes   = $::os_service_default,
  $auth_type                          = 'password',
  $username                           = 'nova',
  $project_domain_name                = 'Default',
  $project_name                       = 'services',
  $user_domain_name                   = 'Default',
  $auth_url                           = 'http://127.0.0.1:5000',
  $region_name                        = $::os_service_default,
  $endpoint_type                      = $::os_service_default,
) {

  include neutron::deps

  $password_real = pick($::neutron::server::notifications::password, $password)
  if $password_real == undef {
    fail('password should be set')
  }

  $auth_type_real = pick($::neutron::server::notifications::auth_type, $auth_type)
  $username_real = pick($::neutron::server::notifications::username, $username)
  $project_name_real = pick($::neutron::server::notifications::project_name, $project_name)
  $user_domain_name_real = pick(
    $::neutron::server::notifications::user_domain_name,
    $user_domain_name)
  $project_domain_name_real = pick(
    $::neutron::server::notifications::project_domain_name,
    $project_domain_name)
  $auth_url_real = pick($::neutron::server::notifications::auth_url, $auth_url)
  $region_name_real = pick($::neutron::server::notifications::region_name, $region_name)
  $endpoint_type_real = pick($::neutron::server::notifications::endpoint_type, $endpoint_type)

  neutron_config {
    'nova/auth_url':            value => $auth_url_real;
    'nova/username':            value => $username_real;
    'nova/password':            value => $password_real, secret => true;
    'nova/project_domain_name': value => $project_domain_name_real;
    'nova/project_name':        value => $project_name_real;
    'nova/user_domain_name':    value => $user_domain_name_real;
    'nova/region_name':         value => $region_name_real;
    'nova/endpoint_type':       value => $endpoint_type_real;
    'nova/auth_type':           value => $auth_type_real;
  }

  $notify_nova_on_port_status_changes_real = pick(
    $::neutron::server::notifications::notify_nova_on_port_status_changes,
    $notify_nova_on_port_status_changes)
  $notify_nova_on_port_data_changes_real = pick(
    $::neutron::server::notifications::notify_nova_on_port_data_changes,
    $notify_nova_on_port_data_changes)

  neutron_config {
    'DEFAULT/notify_nova_on_port_status_changes': value => $notify_nova_on_port_status_changes_real;
    'DEFAULT/notify_nova_on_port_data_changes':   value => $notify_nova_on_port_data_changes_real;
  }
}
