# == Class: neutron::keystone::auth
#
# Configures Neutron user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (Required) Password for Neutron user.
#
# [*auth_name*]
#   (Optional) Username for Neutron service.
#   Defaults to 'neutron'.
#
# [*email*]
#   (Optional) Email for Neutron user.
#   Defaults to 'neutron@localhost'.
#
# [*tenant*]
#   (Optional) Tenant for Neutron user.
#   Defaults to 'services'.
#
# [*roles*]
#   (Optional) List of roles assigned to neutron user.
#   Defaults to ['admin', 'service']
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to 'all'
#
# [*system_roles*]
#   (Optional) List of system roles assigned to neutron user.
#   Defaults to []
#
# [*configure_endpoint*]
#   (Optional) Should Neutron endpoint be configured?
#   Defaults to true.
#
# [*configure_user*]
#   (Optional) Should the Neutron service user be configured?
#   Defaults to true.
#
# [*configure_user_role*]
#   (Optional) Should the admin role be configured for the service user?
#   Defaults to true.
#
# [*configure_service*]
#   (Optional) Should the service be configurd?
#   Defaults to True
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults 'neutron'.
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'network'.
#
# [*service_description*]
#   (Optional) Description for keystone service.
#   Defaults to 'Neutron Networking Service'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*public_url*]
#   (Optional) The endpoint's public url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:9696'
#
# [*admin_url*]
#   (Optional) The endpoint's admin url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:9696'
#
# [*internal_url*]
#   (Optional) The endpoint's internal url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:9696'
#
# === Examples
#
#  class { 'neutron::keystone::auth':
#    public_url   => 'https://10.0.0.10:9696',
#    internal_url => 'https://10.0.0.11:9696',
#    admin_url    => 'https://10.0.0.11:9696',
#  }
#
class neutron::keystone::auth (
  String[1] $password,
  String[1] $auth_name                    = 'neutron',
  String[1] $email                        = 'neutron@localhost',
  String[1] $tenant                       = 'services',
  Array[String[1]] $roles                 = ['admin', 'service'],
  String[1] $system_scope                 = 'all',
  Array[String[1]] $system_roles          = [],
  Boolean $configure_endpoint             = true,
  Boolean $configure_user                 = true,
  Boolean $configure_user_role            = true,
  Boolean $configure_service              = true,
  String[1] $service_name                 = 'neutron',
  String[1] $service_type                 = 'network',
  String[1] $service_description          = 'OpenStack Networking Service',
  String[1] $region                       = 'RegionOne',
  Keystone::PublicEndpointUrl $public_url = 'http://127.0.0.1:9696',
  Keystone::EndpointUrl $admin_url        = 'http://127.0.0.1:9696',
  Keystone::EndpointUrl $internal_url     = 'http://127.0.0.1:9696',
) {
  include neutron::deps

  Keystone::Resource::Service_identity['neutron'] -> Anchor['neutron::service::end']

  keystone::resource::service_identity { 'neutron':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    configure_service   => $configure_service,
    service_type        => $service_type,
    service_description => $service_description,
    service_name        => $service_name,
    auth_name           => $auth_name,
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    roles               => $roles,
    system_scope        => $system_scope,
    system_roles        => $system_roles,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }
}
