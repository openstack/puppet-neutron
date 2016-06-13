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
# [*password*]
#   Password for connection to nova in admin context.
#   Either password or nova_admin_password is required
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
# [*project_name*]
#   (optional) Nova project's name
#   Defaults to 'services'
#
# [*user_domain_id*]
#   (optional) User's domain ID for connection to nova in admin context
#   Defaults to 'default'
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
# === Deprecated Parameters
#
# [*nova_admin_auth_url*]
#   Deprecated. Auth plugins based authentication should be used instead
#   Authorization URL for connection to nova in admin context.
#   Defaults to 'http://127.0.0.1:35357/v2.0'
#
# [*nova_admin_username*]
#   Deprecated. Auth plugins based authentication should be used instead
#   (optional) Username for connection to nova in admin context
#   Defaults to 'nova'
#
# [*nova_admin_tenant_name*]
#   Deprecated. Auth plugins based authentication should be used instead
#   The name of the admin nova tenant
#   Defaults to 'services'
#
# [*nova_admin_tenant_id*]
#   Deprecated. Auth plugins based authentication should be used instead
#   The UUID of the admin nova tenant. If provided this takes precedence
#   over nova_admin_tenant_name.
#
# [*nova_admin_password*]
#   Deprecated. Auth plugins based authentication should be used instead
#   Password for connection to nova in admin context.
#   Either nova_admin_password or password is required
#
# [*nova_region_name*]
#   Deprecated. region_name parameter should be used instead
#   Name of nova region to use. Useful if keystone manages more than
#   one region.
#   Defaults to $::os_service_default
#
# [*auth_plugin*]
#   Deprecated. auth_type should be used instead
#   An authentication plugin to use with an OpenStack Identity server.
#   Defaults to $::os_service_default
#
# [*nova_url*]
#   Deprecated URL for connection to nova (Only supports one nova region
#   currently).
#   Defaults to $::os_service_default
#

class neutron::server::notifications (
  $notify_nova_on_port_status_changes = true,
  $notify_nova_on_port_data_changes   = true,
  $send_events_interval               = $::os_service_default,
  $auth_type                          = 'password',
  $username                           = 'nova',
  $password                           = false,
  $tenant_id                          = $::os_service_default,
  $tenant_name                        = 'services',
  $project_domain_id                  = 'default',
  $project_name                       = 'services',
  $user_domain_id                     = 'default',
  $auth_url                           = 'http://127.0.0.1:35357',
  $region_name                        = $::os_service_default,
  # DEPRECATED PARAMETERS
  $nova_admin_auth_url                = 'http://127.0.0.1:35357/v2.0',
  $nova_admin_username                = 'nova',
  $nova_admin_tenant_name             = 'services',
  $nova_admin_tenant_id               = $::os_service_default,
  $nova_admin_password                = false,
  $nova_region_name                   = $::os_service_default,
  $auth_plugin                        = $::os_service_default,
  $nova_url                           = $::os_service_default,
) {

  include ::neutron::deps

  # Depend on the specified keystone_user resource, if it exists.
  Keystone_user <| title == 'nova' |> -> Class[neutron::server::notifications]

  if ! $nova_admin_password and ! $password {
    fail('nova_admin_password or password must be set.')
  }

  if $nova_admin_password and is_service_default($nova_admin_tenant_id) and (! $nova_admin_tenant_name) {
    fail('You must provide either nova_admin_tenant_name or nova_admin_tenant_id.')
  }

  if $password and is_service_default($tenant_id) and (! $tenant_name) {
    fail('You must provide either tenant_name or tenant_id.')
  }

  if ! is_service_default ($nova_url) {
    warning('nova_url is deprecated and will be removed after Newton cycle.')
  }

  if $nova_admin_password {
    warning('nova_admin-* and nova_region_name parameters are deprecated and will be removed in a future release')
    neutron_config {
      'DEFAULT/nova_admin_auth_url': value => $nova_admin_auth_url;
      'DEFAULT/nova_admin_username': value => $nova_admin_username;
      'DEFAULT/nova_admin_password': value => $nova_admin_password, secret => true;
      'DEFAULT/nova_region_name':    value => $nova_region_name;
    }

    if ! is_service_default ($nova_admin_tenant_id) {
      if $nova_admin_tenant_id {
        neutron_config {
          'DEFAULT/nova_admin_tenant_id': value => $nova_admin_tenant_id;
        }
      }
    } else {
      neutron_config {
        'DEFAULT/nova_admin_tenant_name': value => $nova_admin_tenant_name;
      }
    }
  }

  if $password {
    neutron_config {
      'nova/auth_url':          value => $auth_url;
      'nova/username':          value => $username;
      'nova/password':          value => $password, secret => true;
      'nova/project_domain_id': value => $project_domain_id;
      'nova/project_name':      value => $project_name;
      'nova/user_domain_id':    value => $user_domain_id;
      'nova/region_name':       value => $region_name;
    }
    if ! is_service_default ($auth_plugin) and ($auth_plugin) {
      warning('auth_plugin parameter is deprecated, auth_type should be used instead')
      neutron_config {
        'nova/auth_plugin': value => $auth_plugin;
      }
    } else {
      neutron_config {
        'nova/auth_type': value => $auth_type;
      }
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
  }

  neutron_config {
    'DEFAULT/notify_nova_on_port_status_changes': value => $notify_nova_on_port_status_changes;
    'DEFAULT/notify_nova_on_port_data_changes':   value => $notify_nova_on_port_data_changes;
    'DEFAULT/send_events_interval':               value => $send_events_interval;
    'DEFAULT/nova_url':                           value => $nova_url;
  }
}
