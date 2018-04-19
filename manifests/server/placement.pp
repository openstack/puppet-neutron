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
# == Class: neutron::server::placement
#
# Configure Placement API Options
#
# === Parameters
#
# [*password*]
#   (required) Password for connection to nova in admin context.
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

class neutron::server::placement (
  $password,
  $auth_type           = 'password',
  $username            = 'nova',
  $project_domain_id   = 'default',
  $project_domain_name = 'Default',
  $project_name        = 'services',
  $user_domain_id      = 'default',
  $user_domain_name    = 'Default',
  $auth_url            = 'http://127.0.0.1:35357',
  $region_name         = $::os_service_default,
  $endpoint_type       = $::os_service_default,
) {

  include ::neutron::deps

  neutron_config {
    'placement/auth_url':            value => $auth_url;
    'placement/username':            value => $username;
    'placement/password':            value => $password, secret => true;
    'placement/project_domain_id':   value => $project_domain_id;
    'placement/project_domain_name': value => $project_domain_name;
    'placement/project_name':        value => $project_name;
    'placement/user_domain_id':      value => $user_domain_id;
    'placement/user_domain_name':    value => $user_domain_name;
    'placement/region_name':         value => $region_name;
    'placement/endpoint_type':       value => $endpoint_type;
    'placement/auth_type':           value => $auth_type;
  }

}
