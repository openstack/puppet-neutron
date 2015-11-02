# This class installs and configures Opencontrail Neutron Plugin.
#
# === Parameters
#
# [*api_server_ip*]
#   IP address of the API Server
#   Defaults to $::os_service_default
#
# [*api_server_port*]
#   Port of the API Server.
#   Defaults to $::os_service_default
#
# [*multi_tenancy*]
#   Whether to enable multi-tenancy
#   Default to $::os_service_default
#
# [*contrail_extensions*]
#   Array of OpenContrail extensions to be supported
#   Defaults to $::os_service_default
#   Example:
#
#     class {'neutron::plugins::opencontrail' :
#       contrail_extensions => ['ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam']
#     }
#
# [*keystone_auth_url*]
#   Url of the keystone auth server
#   Defaults to $::os_service_default
#
# [*keystone_admin_user*]
#   Admin user name
#   Defaults to $::os_service_default
#
# [*keystone_admin_tenant_name*]
#   Admin_tenant_name
#   Defaults to $::os_service_default
#
# [*keystone_admin_password*]
#   Admin password
#   Defaults to $::os_service_default
#
# [*keystone_admin_token*]
#   Admin token
#   Defaults to $::os_service_default
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
class neutron::plugins::opencontrail (
  $api_server_ip              = $::os_service_default,
  $api_server_port            = $::os_service_default,
  $multi_tenancy              = $::os_service_default,
  $contrail_extensions        = $::os_service_default,
  $keystone_auth_url          = $::os_service_default,
  $keystone_admin_user        = $::os_service_default,
  $keystone_admin_tenant_name = $::os_service_default,
  $keystone_admin_password    = $::os_service_default,
  $keystone_admin_token       = $::os_service_default,
  $package_ensure             = 'present',
) {

  include ::neutron::params

  validate_array($contrail_extensions)

  package { 'neutron-plugin-contrail':
    ensure => $package_ensure,
    name   => $::neutron::params::opencontrail_plugin_package,
    tag    => 'openstack',
  }

  Neutron_plugin_opencontrail<||> ~> Service['neutron-server']

  ensure_resource('file', '/etc/neutron/plugins/opencontrail', {
    ensure => directory,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640'}
  )

  # Ensure the neutron package is installed before config is set
  # under both RHEL and Ubuntu
  if ($::neutron::params::server_package) {
    Package['neutron-server'] -> Neutron_plugin_opencontrail<||>
  } else {
    Package['neutron'] -> Neutron_plugin_opencontrail<||>
  }

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path    => '/etc/default/neutron-server',
      match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line    => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::opencontrail_config_file}",
      require => [ Package['neutron-server'], Package[$::neutron::params::opencontrail_plugin_package] ],
      notify  => Service['neutron-server'],
    }
  }

  if $::osfamily == 'Redhat' {
    file { '/etc/neutron/plugin.ini':
      ensure  => link,
      target  => $::neutron::params::opencontrail_config_file,
      require => Package[$::neutron::params::opencontrail_plugin_package],
    }
  }

  neutron_plugin_opencontrail {
    'APISERVER/api_server_ip':       value => $api_server_ip;
    'APISERVER/api_server_port':     value => $api_server_port;
    'APISERVER/multi_tenancy':       value => $multi_tenancy;
    'APISERVER/contrail_extensions': value => join($contrail_extensions, ',');
    'KEYSTONE/auth_url':             value => $keystone_auth_url;
    'KEYSTONE/admin_user' :          value => $keystone_admin_user;
    'KEYSTONE/admin_tenant_name':    value => $keystone_admin_tenant_name;
    'KEYSTONE/admin_password':       value => $keystone_admin_password, secret =>true;
    'KEYSTONE/admin_token':          value => $keystone_admin_token, secret =>true;
  }

}
