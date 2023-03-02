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
# == Class: neutron::server::notifications::ironic
#
# Configure notifications to ironic
#
# === Parameters
#
# [*password*]
#   (required) Password for connection to ironic in admin context.
#
# [*auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name
#   Defaults to 'password'
#
# [*user_domain_name*]
#   (optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*username*]
#   (optional) Username for connection to ironic in admin context
#   Defaults to 'ironic'
#
# [*project_domain_name*]
#   (optional) Name of domain for $project_name
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) ironic project's name
#   Defaults to 'services'
#
# [*system_scope*]
#   (optional) Scope for system operations
#   Defaults to $facts['os_service_default']
#
# [*auth_url*]
#   (optional) Authorization URL for connection to ironic in admin context.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://127.0.0.1:5000'
#
# [*region_name*]
#   (optional) Name of ironic region to use. Useful if keystone manages more than
#   one region.
#   Defaults to $facts['os_service_default']
#
# [*valid_interfaces*]
#   (optional) Interface names used for getting the keystone endpoint for
#   the ironic API. Comma separated if multiple.
#   Defaults to $facts['os_service_default']
#
# [*enable_notifications*]
#   (optional) Send notification events to ironic
#   Defaults to $facts['os_service_default']
#
class neutron::server::notifications::ironic (
  $password,
  $auth_type            = 'password',
  $username             = 'ironic',
  $user_domain_name     = 'Default',
  $project_domain_name  = 'Default',
  $project_name         = 'services',
  $system_scope         = $facts['os_service_default'],
  $auth_url             = 'http://127.0.0.1:5000',
  $region_name          = $facts['os_service_default'],
  $valid_interfaces     = $facts['os_service_default'],
  $enable_notifications = $facts['os_service_default'],
) {

  include neutron::deps

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $facts['os_service_default']
    $project_domain_name_real = $facts['os_service_default']
  }

  neutron_config {
    'ironic/auth_type':            value => $auth_type;
    'ironic/user_domain_name':     value => $user_domain_name;
    'ironic/username':             value => $username;
    'ironic/password':             value => $password, secret => true;
    'ironic/project_domain_name':  value => $project_domain_name_real;
    'ironic/project_name':         value => $project_name_real;
    'ironic/system_scope':         value => $system_scope;
    'ironic/auth_url':             value => $auth_url;
    'ironic/region_name':          value => $region_name;
    'ironic/valid_interfaces':     value => join(any2array($valid_interfaces), ',');
    'ironic/enable_notifications': value => $enable_notifications;
  }
}
