#
# Set config file parameters for connecting Neutron server to Big
# Switch controllers.
#
# === Parameters
#
# [*servers*]
# Comma-separated list of Big Switch controllers.
# The format is "IP:port,IP:port".
# Defaults to $::os_service_default
#
# [*server_auth*]
# Credentials for the Big Switch controllers.
# The format is "username:password".
# Defaults to $::os_service_default
#
# [*auth_tenant*]
# (optional) The tenant of the auth user
# Defaults to service
#
# [*auth_password*]
# (optional) The password to use for authentication (keystone)
# Defaults to false.
#
# [*auth_user*]
# (optional) The name of the auth user
# Defaults to neutron
#
# [*auth_url*]
# (optional) Complete public Identity API endpoint.
# Defaults to: false
#
# [*auto_sync_on_failure*]
# (optional) When a failover happens in active/passive Big Switch
# controllers, resynchronize with the new master server. Defaults to
# true.
# Defaults to $::os_service_default
#
# [*cache_connections*]
# (optional) Re-use HTTP/HTTPS connections to the controller.
# Defaults to $::os_service_default
#
# [*consistency_interval*]
# (optional) Interval of a keepalive message sent from Neutron server
# to a Big Switch controller..
# Defaults to $::os_service_default
#
# [*keystone_sync_interval*]
# (optional) Time between openstack tenant sync queries
# Defaults to $::os_service_default
#
# [*neutron_id*]
# (optional) Unique identifier of the Neutron instance for the Big
# Switch controller. Defaults to 'neutron'.
#
# [*no_ssl_validation*]
# (optional) Disables SSL certificate validaiton for controllers
# Defaults to $::os_service_default
#
# [*server_ssl*]
# (optional) Whether Neutron should use SSL to talk to the Big Switch
# controllers.
# Defaults to $::os_service_default
#
# [*server_timeout*]
# (optional) Maximum number of seconds to wait for proxy request to connect
# and complete.
# Defaults to $::os_service_default
#
# [*ssl_cert_directory*]
# (optional) Directory where Big Switch controller certificate will be
# stored. Defaults to '/var/lib/neutron'.
#
# [*sync_data*]
# (optional) Sync data on connect
# Defaults to $::os_service_default
#
# [*thread_pool_size*]
# (optional) Maximum number of threads to spawn to handle large volumes of
# port creations.
# Defaults to $::os_service_default
#
class neutron::plugins::ml2::bigswitch::restproxy (
  $servers                = $::os_service_default,
  $server_auth            = $::os_service_default,
  $auth_tenant            = 'service',
  $auth_password          = false,
  $auth_user              = 'neutron',
  $auth_url               = false,
  $auto_sync_on_failure   = $::os_service_default,
  $cache_connections      = $::os_service_default,
  $consistency_interval   = $::os_service_default,
  $keystone_sync_interval = $::os_service_default,
  $neutron_id             = 'neutron',
  $no_ssl_validation      = $::os_service_default,
  $server_ssl             = $::os_service_default,
  $server_timeout         = $::os_service_default,
  $ssl_cert_directory     = '/var/lib/neutron',
  $sync_data              = $::os_service_default,
  $thread_pool_size       = $::os_service_default,
) {

  include ::neutron::deps
  require ::neutron::plugins::ml2::bigswitch

  neutron_plugin_ml2 {
    'restproxy/servers'               : value => $servers;
    'restproxy/server_auth'           : value => $server_auth;
    'restproxy/auth_tenant'           : value => $auth_tenant;
    'restproxy/auth_password'         : value => $auth_password, secret => true;
    'restproxy/auth_user'             : value => $auth_user;
    'restproxy/auth_url'              : value => $auth_url;
    'restproxy/auto_sync_on_failure'  : value => $auto_sync_on_failure;
    'restproxy/cache_connections'     : value => $cache_connections;
    'restproxy/consistency_interval'  : value => $consistency_interval;
    'restproxy/keystone_sync_interval': value => $keystone_sync_interval;
    'restproxy/neutron_id'            : value => $neutron_id;
    'restproxy/no_ssl_validation'     : value => $no_ssl_validation;
    'restproxy/server_ssl'            : value => $server_ssl;
    'restproxy/server_timeout'        : value => $server_timeout;
    'restproxy/ssl_cert_directory'    : value => $ssl_cert_directory;
    'restproxy/sync_data'             : value => $sync_data;
    'restproxy/thread_pool_size'      : value => $thread_pool_size;
  }
}
