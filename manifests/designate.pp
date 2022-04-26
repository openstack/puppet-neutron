# == Class: neutron::designate
#
#  Configure the Neutron designate DNS driver
#
# === Parameters
#
# [*password*]
#   (required) Password for connection to designate in admin context.
#
# [*url*]
#   (required) URL to the designate service.
#
# [*auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name
#   Defaults to 'password'
#
# [*username*]
#   (optional) Username for connection to designate in admin context
#   Defaults to 'neutron'
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) The name of the admin project
#   Defaults to 'services'
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to 'Default'
#
# [*system_scope*]
#   (Optional) Scope for system operations
#   Defaults to $::os_service_default
#
# [*auth_url*]
#   (optional) Authorization URI for connection to designate in admin context.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://127.0.0.1:5000'
#
# [*cafile*]
#   (Optional) A PEM encoded Certificate Authority to use when verifying HTTPs
#   connections.
#   Defaults to $::os_service_default.
#
# [*certfile*]
#   (Optional) Required if identity server requires client certificate
#   Defaults to $::os_service_default.
#
# [*allow_reverse_dns_lookup*]
#   (optional) Enable or not the creation of reverse lookup (PTR) records.
#
# [*ipv4_ptr_zone_prefix_size*]
#   (optional) Enable or not the creation of reverse lookup (PTR) records.
#
# [*ipv6_ptr_zone_prefix_size*]
#   (optional) Enable or not the creation of reverse lookup (PTR) records.
#
# [*ptr_zone_email*]
#   (optional) The email address to be used when creating PTR zones.
#
class neutron::designate (
  $password,
  $url,
  $auth_type                 = 'password',
  $username                  = 'neutron',
  $user_domain_name          = 'Default',
  $project_name              = 'services',
  $project_domain_name       = 'Default',
  $system_scope              = $::os_service_default,
  $auth_url                  = 'http://127.0.0.1:5000',
  $cafile                    = $::os_service_default,
  $certfile                  = $::os_service_default,
  $allow_reverse_dns_lookup  = $::os_service_default,
  $ipv4_ptr_zone_prefix_size = $::os_service_default,
  $ipv6_ptr_zone_prefix_size = $::os_service_default,
  $ptr_zone_email            = $::os_service_default,
) {
  include neutron::deps
  include neutron::params

  if is_service_default($system_scope){
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $::os_service_default
    $project_domain_name_real = $::os_service_default
  }

  neutron_config {
    'DEFAULT/external_dns_driver':         value => 'designate';
    'designate/password':                  value => $password, secret => true;
    'designate/url':                       value => $url;
    'designate/auth_type':                 value => $auth_type;
    'designate/username':                  value => $username;
    'designate/user_domain_name':          value => $user_domain_name;
    'designate/project_name':              value => $project_name_real;
    'designate/project_domain_name':       value => $project_domain_name_real;
    'designate/system_scope':              value => $system_scope;
    'designate/auth_url':                  value => $auth_url;
    'designate/cafile':                    value => $cafile;
    'designate/certfile':                  value => $certfile;
    'designate/allow_reverse_dns_lookup':  value => $allow_reverse_dns_lookup;
    'designate/ipv4_ptr_zone_prefix_size': value => $ipv4_ptr_zone_prefix_size;
    'designate/ipv6_ptr_zone_prefix_size': value => $ipv6_ptr_zone_prefix_size;
    'designate/ptr_zone_email':            value => $ptr_zone_email;
  }
}
