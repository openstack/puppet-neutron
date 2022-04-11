# This class installs and configures Opencontrail Neutron Plugin.
#
# === Parameters
#
# [*api_server_ip*]
#   (Optional) IP address of the API Server
#   Defaults to $::os_service_default
#
# [*api_server_port*]
#   (Optional) Port of the API Server.
#   Defaults to $::os_service_default
#
# [*multi_tenancy*]
#   (Optional) Whether to enable multi-tenancy
#   Default to $::os_service_default
#
# [*contrail_extensions*]
#   (Optional) Array of OpenContrail extensions to be supported
#   Defaults to $::os_service_default
#   Example:
#
#     class {'neutron::plugins::opencontrail' :
#       contrail_extensions => ['ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam']
#     }
#
# [*timeout*]
#   (Optional) VNC API Server request timeout in seconds.
#   Defaults to $::os_service_default
#
# [*connection_timeout*]
#   (Optional) VNC API Server connection timeout in seconds.
#   Defaults to $::os_service_default
#
# [*package_ensure*]
#   (Optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified config options
#   in the opencontrail config.
#   Defaults to false.
#
# DEPRECATED PARAMETERS
#
# [*keystone_auth_url*]
#   Url of the keystone auth server
#   Defaults to undef
#
# [*keystone_admin_user*]
#   Admin user name
#   Defaults to undef
#
# [*keystone_admin_tenant_name*]
#   Admin_tenant_name
#   Defaults to undef
#
# [*keystone_admin_password*]
#   Admin password
#   Defaults to undef
#
# [*keystone_admin_token*]
#   Admin token
#   Defaults to undef
#
class neutron::plugins::opencontrail (
  $api_server_ip              = $::os_service_default,
  $api_server_port            = $::os_service_default,
  $multi_tenancy              = $::os_service_default,
  $contrail_extensions        = $::os_service_default,
  $timeout                    = $::os_service_default,
  $connection_timeout         = $::os_service_default,
  $package_ensure             = 'present',
  $purge_config               = false,
  # DEPRECATED PARAMETERS
  $keystone_auth_url          = undef,
  $keystone_admin_user        = undef,
  $keystone_admin_tenant_name = undef,
  $keystone_admin_password    = undef,
  $keystone_admin_token       = undef,
) {

  include neutron::deps
  include neutron::params

  [
    'keystone_auth_url',
    'keystone_admin_user',
    'keystone_admin_tenant_name',
    'keystone_admin_password',
    'keystone_admin_token'
  ].each |String $key_opt| {
    if getvar($key_opt) != undef {
      warning("The ${key_opt} parameter is deprecated and has no effect.")
    }
  }

  validate_legacy(Array, 'validate_array', $contrail_extensions)

  package { 'neutron-plugin-contrail':
    ensure => $package_ensure,
    name   => $::neutron::params::opencontrail_plugin_package,
    tag    => ['openstack', 'neutron-package'],
  }

  ensure_resource('file', '/etc/neutron/plugins/opencontrail', {
    ensure => directory,
    owner  => 'root',
    group  => $::neutron::params::group,
    mode   => '0640'}
  )

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path  => '/etc/default/neutron-server',
      match => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line  => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::opencontrail_config_file}",
      tag   => 'neutron-file-line',
    }
  }

  if $::osfamily == 'Redhat' {
    file { '/etc/neutron/plugin.ini':
      ensure  => link,
      target  => $::neutron::params::opencontrail_config_file,
      require => Package[$::neutron::params::opencontrail_plugin_package],
      tag     => 'neutron-config-file',
    }
  }

  resources { 'neutron_plugin_opencontrail':
    purge => $purge_config,
  }

  neutron_plugin_opencontrail {
    'APISERVER/api_server_ip':       value => $api_server_ip;
    'APISERVER/api_server_port':     value => $api_server_port;
    'APISERVER/multi_tenancy':       value => $multi_tenancy;
    'APISERVER/contrail_extensions': value => join($contrail_extensions, ',');
    'APISERVER/timeout':             value => $timeout;
    'APISERVER/connection_timeout':  value => $connection_timeout;
  }

  neutron_plugin_opencontrail {
    'KEYSTONE/auth_url':          ensure => absent;
    'KEYSTONE/admin_user' :       ensure => absent;
    'KEYSTONE/admin_tenant_name': ensure => absent;
    'KEYSTONE/admin_password':    ensure => absent;
    'KEYSTONE/admin_token':       ensure => absent;
  }

}
