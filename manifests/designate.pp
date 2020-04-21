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
# [*project_id*]
#   (optional) The UUID of the admin designate project. If provided this takes
#   precedence over project_name.
#
# [*project_name*]
#   (optional) The name of the admin project
#   Defaults to 'services'
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to 'Default'
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*auth_url*]
#   (optional) Authorization URI for connection to designate in admin context.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://127.0.0.1:5000'
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
# DEPRECATED PARAMETERS
#
# [*project_domain_id*]
#   (optional) Nova project's domain ID
#   Defaults to undef
#
# [*user_domain_id*]
#   (optional) User's domain ID for connection to designate in admin context
#   Defaults to undef
#
class neutron::designate (
  $password,
  $url,
  $auth_type                 = 'password',
  $username                  = 'neutron',
  $project_id                = $::os_service_default,
  $project_name              = 'services',
  $project_domain_name       = 'Default',
  $user_domain_name          = 'Default',
  $auth_url                  = 'http://127.0.0.1:5000',
  $allow_reverse_dns_lookup  = $::os_service_default,
  $ipv4_ptr_zone_prefix_size = $::os_service_default,
  $ipv6_ptr_zone_prefix_size = $::os_service_default,
  $ptr_zone_email            = $::os_service_default,
  # DEPRECATED PARAMETERS
  $project_domain_id         = undef,
  $user_domain_id            = undef,
) {
  include neutron::deps
  include neutron::params

  neutron_config {
    'DEFAULT/external_dns_driver':         value => 'designate';
    'designate/password':                  value => $password;
    'designate/url':                       value => $url;
    'designate/auth_type':                 value => $auth_type;
    'designate/username':                  value => $username;
    'designate/project_id':                value => $project_id;
    'designate/project_name':              value => $project_name;
    'designate/project_domain_name':       value => $project_domain_name;
    'designate/user_domain_name':          value => $user_domain_name;
    'designate/auth_url':                  value => $auth_url;
    'designate/allow_reverse_dns_lookup':  value => $allow_reverse_dns_lookup;
    'designate/ipv4_ptr_zone_prefix_size': value => $ipv4_ptr_zone_prefix_size;
    'designate/ipv6_ptr_zone_prefix_size': value => $ipv6_ptr_zone_prefix_size;
    'designate/ptr_zone_email':            value => $ptr_zone_email;
  }

  if $project_domain_id != undef {
    warning('project_domain_id is deprecated and will be removed in a future release. \
Use project_domain_name instead')
    neutron_config {
      'designate/project_domain_id': value => $project_domain_id;
    }
  }

  if $user_domain_id != undef {
    warning('user_domain_id is deprecated and will be removed in a future release. \
Use user_domain_name instead')
    neutron_config {
      'designate/user_domain_id': value => $user_domain_id;
    }
  }
}
