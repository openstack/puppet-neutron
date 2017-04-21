# == Class: neutron::keystone::auth
#
# Configures Neutron user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for Neutron user.
#
# [*auth_name*]
#   Username for Neutron service. Defaults to 'neutron'.
#
# [*email*]
#   Email for Neutron user. Defaults to 'neutron@localhost'.
#
# [*tenant*]
#   Tenant for Neutron user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should Neutron endpoint be configured? Defaults to 'true'.
#
# [*configure_user*]
#   Should the Neutron service user be configured? Defaults to 'true'.
#
# [*configure_user_role*]
#   Should the admin role be configured for the service user?
#   Defaults to 'true'.
#
# [*service_name*]
#   Name of the service. Defaults 'neutron'.
#
# [*service_type*]
#   Type of service. Defaults to 'network'.
#
# [*service_description*]
#   Description for keystone service.
#   (optional) Defaults to 'Neutron Networking Service'.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:9696')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:9696')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:9696')
#   This url should *not* contain any trailing '/'.
#
# === Examples
#
#  class { 'neutron::keystone::auth':
#    public_url   => 'https://10.0.0.10:9696',
#    internal_url => 'https://10.0.0.11:9696',
#    admin_url    => 'https://10.0.0.11:9696',
#  }
#
#
class neutron::keystone::auth (
  $password,
  $auth_name           = 'neutron',
  $email               = 'neutron@localhost',
  $tenant              = 'services',
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = 'neutron',
  $service_type        = 'network',
  $service_description = 'Neutron Networking Service',
  $region              = 'RegionOne',
  $public_url          = 'http://127.0.0.1:9696',
  $admin_url           = 'http://127.0.0.1:9696',
  $internal_url        = 'http://127.0.0.1:9696',
) {

  include ::neutron::deps

  if $configure_endpoint {
    Keystone_endpoint["${region}/${service_name}::${service_type}"]  ~> Service <| tag == 'neutron-server-eventlet' |>
  }

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| tag == 'neutron-server-eventlet' |>
  }

  keystone::resource::service_identity { 'neutron':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => $service_description,
    service_name        => $service_name,
    auth_name           => $auth_name,
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }

}
