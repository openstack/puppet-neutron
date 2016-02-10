# This class installs and configures Plumgrid Neutron Plugin.
#
# === Parameters
#
# [*director_server*]
#   IP address of the PLUMgrid Director Server
#   Defaults to 127.0.0.1
#
# [*director_server_port*]
#   Port of the PLUMgrid Director Server.
#   Defaults to 443
#
# [*username*]
#   PLUMgrid platform username
#   Defaults to $::os_service_default
#
# [*password*]
#   PLUMgrid platform password
#   Defaults to $::os_service_default
#
# [*servertimeout*]
#   Request timeout duration (seconds) to PLUMgrid paltform
#   Defaults to 99
#
# [*connection*]
#   Database connection
#   Defaults to http://127.0.0.1:35357/v2.0
#
# [*admin_password*]
#   Keystone admin password
#   Defaults to $::os_service_default
#
# [*controller_priv_host*]
#   Controller private host IP
#   Defaults to 127.0.0.1
#
# [*auth_protocol*]
#   Authorization protocol
#   Defaults to http
#
# [*identity_version*]
#   Keystone identity version
#   Defaults to v2.0
#
# [*nova_metadata_ip*]
#   Nova metadata IP
#   Defaults to 127.0.0.1
#
# [*nova_metadata_port*]
#   Nova metadata port
#   Defaults to 8775
#
# [*metadata_proxy_shared_secret*]
#   Neutron metadata shared secret key
#   Defaults to $::os_service_default
#
# [*connector_type*]
#   Neutron network connector type
#   Defaults to distributed
#
# [*l2gateway_vendor*]
#   L2 gateway vendor
#   Defaults to $::os_service_default
#
# [*l2gateway_sw_username*]
#   L2 gateway username
#   Defaults to $::os_service_default
#
# [*l2gateway_sw_password*]
#   L2 gateway password
#   Defaults to $::os_service_default
#
# [*plumlib_package_ensure*]
#   (optional) Ensure state for plumlib package.
#   Defaults to 'present'.
#
# [*package_ensure*]
#   (optional) Ensure state for plugin package.
#   Defaults to 'present'.
#
class neutron::plugins::plumgrid (
  $director_server              = '127.0.0.1',
  $director_server_port         = '443',
  $username                     = $::os_service_default,
  $password                     = $::os_service_default,
  $servertimeout                = '99',
  $connection                   = 'http://127.0.0.1:35357/v2.0',
  $admin_password               = $::os_service_default,
  $controller_priv_host         = '127.0.0.1',
  $auth_protocol                = 'http',
  $identity_version             = 'v2.0',
  $nova_metadata_ip             = '127.0.0.1',
  $nova_metadata_port           = '8775',
  $metadata_proxy_shared_secret = $::os_service_default,
  $connector_type               = 'distributed',
  $l2gateway_vendor             = $::os_service_default,
  $l2gateway_sw_username        = $::os_service_default,
  $l2gateway_sw_password        = $::os_service_default,
  $plumlib_package_ensure       = 'present',
  $package_ensure               = 'present'
) {

  include ::neutron::params

  Neutron_plugin_plumgrid<||> ~> Service['neutron-server']
  Neutron_plumlib_plumgrid<||> ~> Service['neutron-server']
  Neutron_plugin_plumgrid<||> ~> Exec<| title == 'neutron-db-sync' |>

  ensure_resource('file', '/etc/neutron/plugins/plumgrid', {
    ensure => directory,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640'}
  )

  # Ensure the neutron package is installed before config is set
  # under both RHEL and Ubuntu
  if ($::neutron::params::server_package) {
    Package['neutron-server'] -> Neutron_plugin_plumgrid<||>
    Package['neutron-server'] -> Neutron_plumlib_plumgrid<||>
  } else {
    Package['neutron'] -> Neutron_plugin_plumgrid<||>
    Package['neutron'] -> Neutron_plumlib_plumgrid<||>
  }

  package { 'neutron-plugin-plumgrid':
    ensure => $package_ensure,
    name   => $::neutron::params::plumgrid_plugin_package
  }

  package { 'neutron-plumlib-plumgrid':
    ensure => $plumlib_package_ensure,
    name   => $::neutron::params::plumgrid_pythonlib_package
  }

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path    => '/etc/default/neutron-server',
      match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line    => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::plumgrid_config_file}",
      require => [ Package['neutron-server'], Package['neutron-plugin-plumgrid'] ],
      notify  => Service['neutron-server'],
    }
  }

  if $::osfamily == 'Redhat' {
    file { '/etc/neutron/plugin.ini':
      ensure  => link,
      target  => $::neutron::params::plumgrid_config_file,
      require => Package['neutron-plugin-plumgrid'],
    }
  }

  neutron_plugin_plumgrid {
    'PLUMgridDirector/director_server':      value => $director_server;
    'PLUMgridDirector/director_server_port': value => $director_server_port;
    'PLUMgridDirector/username':             value => $username;
    'PLUMgridDirector/password':             value => $password, secret =>true;
    'PLUMgridDirector/servertimeout':        value => $servertimeout;
    'database/connection':                   value => $connection;
  }

  neutron_plumlib_plumgrid {
    'keystone_authtoken/admin_user' :                value => 'admin';
    'keystone_authtoken/admin_password':             value => $admin_password, secret =>true;
    'keystone_authtoken/auth_uri':                   value => "${auth_protocol}://${controller_priv_host}:35357/${identity_version}";
    'keystone_authtoken/admin_tenant_name':          value => 'admin';
    'keystone_authtoken/identity_version':           value => $identity_version;
    'PLUMgridMetadata/enable_pg_metadata' :          value => 'True';
    'PLUMgridMetadata/metadata_mode':                value => 'local';
    'PLUMgridMetadata/nova_metadata_ip':             value => $nova_metadata_ip;
    'PLUMgridMetadata/nova_metadata_port':           value => $nova_metadata_port;
    'PLUMgridMetadata/metadata_proxy_shared_secret': value => $metadata_proxy_shared_secret;
    'ConnectorType/connector_type':                  value => $connector_type;
    'l2gateway/vendor':                              value => $l2gateway_vendor;
    'l2gateway/sw_username':                         value => $l2gateway_sw_username;
    'l2gateway/sw_password':                         value => $l2gateway_sw_password;
  }
}
