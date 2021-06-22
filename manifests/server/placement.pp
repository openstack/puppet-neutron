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
#   (required) Password for user used when talking to placement.
#
# [*auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name
#   Defaults to 'password'
#
# [*username*]
#   (optional) Username when talking to placement.
#   Defaults to 'nova'
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) Project name for configured user.
#   Defaults to 'services'
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*auth_url*]
#   (optional) Keystone auth URL.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://127.0.0.1:5000'
#
# [*region_name*]
#   (optional) Name of region to use. Useful if keystone manages more than
#   one region.
#   Defaults to $::os_service_default
#
# [*endpoint_type*]
#   (optional) The type endpoint to use when looking up in
#   the keystone catalog.
#   Defaults to $::os_service_default
#
class neutron::server::placement (
  $password,
  $auth_type           = 'password',
  $username            = 'nova',
  $project_domain_name = 'Default',
  $project_name        = 'services',
  $user_domain_name    = 'Default',
  $auth_url            = 'http://127.0.0.1:5000',
  $region_name         = $::os_service_default,
  $endpoint_type       = $::os_service_default,
) {

  include neutron::deps

  # TODO(tobias-urdin): Update default value to placement in next release.
  if $username == 'nova' {
    warning('The default value of username will change to placement in the next release')
  }

  neutron_config {
    'placement/auth_url':            value => $auth_url;
    'placement/username':            value => $username;
    'placement/password':            value => $password, secret => true;
    'placement/project_domain_name': value => $project_domain_name;
    'placement/project_name':        value => $project_name;
    'placement/user_domain_name':    value => $user_domain_name;
    'placement/region_name':         value => $region_name;
    'placement/endpoint_type':       value => $endpoint_type;
    'placement/auth_type':           value => $auth_type;
  }
}
