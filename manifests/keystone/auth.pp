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
#   (0ptional) The endpoint's public url.
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
  $password,
  $auth_name           = 'neutron',
  $email               = 'neutron@localhost',
  $tenant              = 'services',
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = 'neutron',
  $service_type        = 'network',
  $service_description = 'OpenStack Networking Service',
  $region              = 'RegionOne',
  $public_url          = 'http://127.0.0.1:9696',
  $admin_url           = 'http://127.0.0.1:9696',
  $internal_url        = 'http://127.0.0.1:9696',
) {

  include neutron::deps

  if $configure_endpoint {
    Keystone_endpoint["${region}/${service_name}::${service_type}"] -> Anchor['neutron::service::end']
  }

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] -> Anchor['neutron::service::end']
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
