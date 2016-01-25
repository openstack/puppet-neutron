# == Class: neutron::server
#
# Setup and configure the neutron API endpoint
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*service_name*]
#   (optional) The name of the neutron-server service
#   Defaults to $::neutron::params::server_service
#
# [*log_file*]
#   REMOVED: Use log_file of neutron class instead.
#
# [*log_dir*]
#   REMOVED: Use log_dir of neutron class instead.
#
# [*auth_type*]
#   (optional) What auth system to use
#   Defaults to 'keystone'. Can other be 'noauth'
#
# [*auth_plugin*]
#   (optional) An authentication plugin to use with an OpenStack Identity server.
#   Defaults to $::os_service_default
#
# [*auth_uri*]
#   (optional) Complete public Identity API endpoint.
#   Defaults to: 'http://localhost:5000/'
#
# [*auth_url*]
#   (optional) Authorization URL.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://localhost:35357'
#
# [*username*]
#   (optional) The name of the auth user
#   Defaults to 'neutron'
#
# [*password*]
#   The password to use for authentication (keystone)
#   Either password or auth_password is required
#
# [*tenant_name*]
#   (optional) The tenant of the auth user
#   Defaults to 'services'
#
# [*project_domain_id*]
#   (optional) Auth user project's domain ID
#   Defaults to $::os_service_default
#
# [*project_name*]
#   (optional) Auth user project's name
#   Defaults to $::os_service_default
#
# [*user_domain_id*]
#   (optional) Auth user's domain ID
#   Defaults to $::os_service_default
#
# [*region_name*]
#   (optional) The authentication region
#   Defaults to $::os_service_default
#
# [*database_connection*]
#   (optional) Connection url for the neutron database.
#   (Defaults to undef)
#
# [*sql_connection*]
#   DEPRECATED: Use database_connection instead.
#
# [*connection*]
#   DEPRECATED: Use database_connection instead.
#
# [*database_max_retries*]
#   (optional) Maximum database connection retries during startup.
#   (Defaults to undef)
#
# [*sql_max_retries*]
#   DEPRECATED: Use database_max_retries instead.
#
# [*max_retries*]
#   DEPRECATED: Use database_max_retries instead.
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle database connections are reaped.
#   Deprecates sql_idle_timeout
#   (Defaults to undef)
#
# [*sql_idle_timeout*]
#   DEPRECATED: Use database_idle_timeout instead.
#
# [*idle_timeout*]
#   DEPRECATED: Use database_idle_timeout instead.
#
# [*database_retry_interval*]
#   (optional) Interval between retries of opening a database connection.
#   (Defaults to 10)
#
# [*sql_reconnect_interval*]
#   DEPRECATED: Use database_retry_interval instead.
#
# [*retry_interval*]
#   DEPRECATED: Use database_retry_interval instead.
#
# [*database_min_pool_size*]
#   (optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to: undef.
#
# [*database_max_pool_size*]
#   (optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to: undef.
#
# [*database_max_overflow*]
#   (optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef.
#
# [*sync_db*]
#   (optional) Run neutron-db-manage on api nodes after installing the package.
#   Defaults to false
#
# [*api_workers*]
#   (optional) Number of separate worker processes to spawn.
#   The default, count of machine's processors, runs the worker thread in the
#   current process.
#   Greater than 0 launches that number of child processes as workers.
#   The parent process manages them.
#   Defaults to: $::processorcount
#
# [*rpc_workers*]
#   (optional) Number of separate RPC worker processes to spawn.
#   The default, count of machine's processors, runs the worker thread in the
#   current process.
#   Greater than 0 launches that number of child processes as workers.
#   The parent process manages them.
#   Defaults to: $::processorcount
#
# [*agent_down_time*]
#   (optional) Seconds to regard the agent as down; should be at least twice
#   report_interval, to be sure the agent is down for good.
#   agent_down_time is a config for neutron-server, set by class neutron::server
#   report_interval is a config for neutron agents, set by class neutron
#   Defaults to: $::os_service_default
#
# [*state_path*]
#   (optional) Deprecated.  Use state_path parameter on base neutron class instead.
#
# [*lock_path*]
#   (optional) Deprecated.  Use lock_path parameter on base neutron class instead.
#
# [*router_scheduler_driver*]
#   (optional) Driver to use for scheduling router to a default L3 agent. Could be:
#   neutron.scheduler.l3_agent_scheduler.ChanceScheduler to schedule a router in a random way
#   neutron.scheduler.l3_agent_scheduler.LeastRoutersScheduler to allocate on an L3 agent with the least number of routers bound.
#   Defaults to: neutron.scheduler.l3_agent_scheduler.ChanceScheduler
#
# [*router_distributed*]
#   (optional) Setting the "router_distributed" flag to "True" will default to the creation
#   of distributed tenant routers.
#   Also can be the type of the router on the create request (admin-only attribute).
#   Defaults to $::os_service_default
#
# [*allow_automatic_l3agent_failover*]
#   (optional) Allow automatic rescheduling of routers from dead L3 agents with
#   admin_state_up set to True to alive agents.
#   Defaults to $::os_service_default
#
# [*l3_ha*]
#   (optional) Enable high availability for virtual routers.
#   Defaults to false
#
# [*max_l3_agents_per_router*]
#   (optional) Maximum number of l3 agents which a HA router will be scheduled on. If set to '0', a router will be scheduled on every agent.
#   Defaults to '3'
#
# [*min_l3_agents_per_router*]
#   (optional) Minimum number of l3 agents which a HA router will be scheduled on.
#   Defaults to '2'
#
# [*l3_ha_net_cidr*]
#   (optional) CIDR of the administrative network if HA mode is enabled.
#   Defaults to $::os_service_default
#
# [*report_interval*]
#   (optional) Deprecated, does nothing.
#   Defaults to 'undef'.
#
# [*qos_notification_drivers*]
#   (optional) Drivers list to use to send the update notification
#   Defaults to $::os_service_default.
#
# [*ensure_vpnaas_package*]
#   (optional) Ensures installation of VPNaaS package before starting API service.
#   Set to true to ensure installation of the package that is required to start neutron service if service_plugin is enabled.
#   Defaults to false.
#
# [*ensure_fwaas_package*]
#   (optional) Ensures installation of FWaaS package before starting API service.
#   Set to true to ensure installation of the package that is required to start neutron service if service_plugin is enabled.
#   Defaults to false.
#
# [*ensure_lbaas_package*]
#   (optional) Ensures installation of LBaaS package before starting API service.
#   Set to true to ensure installation of the package that is required to start neutron service if service_plugin is enabled.
#   Defaults to false.
#
# [*vpnaas_agent_package*]
#   (optional) Use VPNaaS agent package instead of L3 agent package on debian platforms
#   RedHat platforms won't take care of this parameter
#   true/false
#   Defaults to false
# === Deprecated Parameters
#
# [*identity_uri*]
#   Deprecated. Auth plugins based authentication should be used instead
#   (optional) Complete admin Identity API endpoint.
#   Defaults to: 'http://localhost:35357/'
#
# [*auth_region*]
#   Deprecated. Auth plugins based authentication should be used instead
#   (optional) The authentication region. Note this value is case-sensitive and
#   must match the endpoint region defined in Keystone.
#   Defaults to $::os_service_default
#
# [*auth_tenant*]
#   Deprecated. Auth plugins based authentication should be used instead
#   (optional) The tenant of the auth user
#   Defaults to services
#
# [*auth_user*]
#   Deprecated. Auth plugins based authentication should be used instead
#   (optional) The name of the auth user
#   Defaults to neutron
#
# [*auth_password*]
#   Deprecated. Auth plugins based authentication should be used instead
#   (optional) The password to use for authentication (keystone)
#   Defaults to false. Set a value unless you are using noauth
#
class neutron::server (
  $package_ensure                   = 'present',
  $enabled                          = true,
  $manage_service                   = true,
  $service_name                     = $::neutron::params::server_service,
  $auth_type                        = 'keystone',
  $auth_plugin                      = $::os_service_default,
  $auth_uri                         = 'http://localhost:5000/',
  $auth_url                         = 'http://localhost:35357/',
  $username                         = 'neutron',
  $password                         = false,
  $tenant_name                      = 'services',
  $region_name                      = $::os_service_default,
  $project_domain_id                = $::os_service_default,
  $project_name                     = $::os_service_default,
  $user_domain_id                   = $::os_service_default,
  $database_connection              = undef,
  $database_max_retries             = undef,
  $database_idle_timeout            = undef,
  $database_retry_interval          = undef,
  $database_min_pool_size           = undef,
  $database_max_pool_size           = undef,
  $database_max_overflow            = undef,
  $sync_db                          = false,
  $api_workers                      = $::processorcount,
  $rpc_workers                      = $::processorcount,
  $agent_down_time                  = $::os_service_default,
  $router_scheduler_driver          = 'neutron.scheduler.l3_agent_scheduler.ChanceScheduler',
  $router_distributed               = $::os_service_default,
  $allow_automatic_l3agent_failover = $::os_service_default,
  $l3_ha                            = false,
  $max_l3_agents_per_router         = 3,
  $min_l3_agents_per_router         = 2,
  $l3_ha_net_cidr                   = $::os_service_default,
  $qos_notification_drivers         = $::os_service_default,
  $ensure_vpnaas_package            = false,
  $ensure_fwaas_package             = false,
  $ensure_lbaas_package             = false,
  $vpnaas_agent_package             = false,
  # DEPRECATED PARAMETERS
  $log_dir                          = undef,
  $log_file                         = undef,
  $report_interval                  = undef,
  $state_path                       = undef,
  $lock_path                        = undef,
  $auth_password                    = false,
  $auth_region                      = $::os_service_default,
  $auth_tenant                      = 'services',
  $auth_user                        = 'neutron',
  $identity_uri                     = 'http://localhost:35357/',
) inherits ::neutron::params {

  include ::neutron::db
  include ::neutron::policy

  if $ensure_fwaas_package {
    if ($::osfamily == 'Debian') {
      # Debian platforms
      if $vpnaas_agent_package {
        ensure_resource( 'package', $::neutron::params::vpnaas_agent_package, {
          'ensure' => $neutron::package_ensure,
          'tag'    => ['openstack', 'neutron-package'],
        })
        Package[$::neutron::params::vpnaas_agent_package] -> Neutron_fwaas_service_config<||>
      } else {
        ensure_resource( 'package', 'neutron-fwaas' , {
          'name'   => $::neutron::params::fwaas_package,
          'ensure' => $neutron::package_ensure,
          'tag'    => ['openstack', 'neutron-package'],
        })
      }
    } elsif($::osfamily == 'Redhat') {
      # RH platforms
      ensure_resource( 'package', 'neutron-fwaas', {
        'name'   => $::neutron::params::fwaas_package,
        'ensure' => $neutron::package_ensure,
        'tag'    => ['openstack', 'neutron-package'],
      })
    }
  }

  if $ensure_vpnaas_package {
    ensure_resource( 'package', 'neutron-vpnaas-agent', {
      'ensure' => $package_ensure,
      'name'   => $::neutron::params::vpnaas_agent_package,
      'tag'    => ['openstack', 'neutron-package'],
    })
  }

  if $ensure_lbaas_package {
    ensure_resource( 'package', 'neutron-lbaas-agent', {
      'ensure' => $package_ensure,
      'name'   => $::neutron::params::lbaas_agent_package,
      'tag'    => ['openstack', 'neutron-package'],
    })
  }



  Neutron_config<||>     ~> Service['neutron-server']
  Neutron_api_config<||> ~> Service['neutron-server']
  Class['neutron::policy'] ~> Service['neutron-server']
  Neutron_config<||> -> Neutron_network<||>

  if $l3_ha {
    if $min_l3_agents_per_router <= $max_l3_agents_per_router or $max_l3_agents_per_router == 0 {
      neutron_config {
        'DEFAULT/l3_ha':                    value => true;
        'DEFAULT/max_l3_agents_per_router': value => $max_l3_agents_per_router;
        'DEFAULT/min_l3_agents_per_router': value => $min_l3_agents_per_router;
        'DEFAULT/l3_ha_net_cidr':           value => $l3_ha_net_cidr;
      }
    } else {
      fail('min_l3_agents_per_router should be less than or equal to max_l3_agents_per_router.')
    }
  } else {
      neutron_config {
        'DEFAULT/l3_ha':                    value => false;
      }
  }


  if $sync_db {
    include ::neutron::db::sync
  }

  neutron_config {
    'DEFAULT/api_workers':                      value => $api_workers;
    'DEFAULT/rpc_workers':                      value => $rpc_workers;
    'DEFAULT/agent_down_time':                  value => $agent_down_time;
    'DEFAULT/router_scheduler_driver':          value => $router_scheduler_driver;
    'DEFAULT/router_distributed':               value => $router_distributed;
    'DEFAULT/allow_automatic_l3agent_failover': value => $allow_automatic_l3agent_failover;
  }

  if $state_path {
    # If we got state_path here, display deprecation warning and override the value from
    # the base class.  This preserves the behavior of before state_path was deprecated.

    warning('The state_path parameter is deprecated.  Use the state_path parameter on the base neutron class instead.')

    Neutron_config <| title == 'DEFAULT/state_path' |> {
      value => $state_path,
    }
  }

  if $lock_path {
    # If we got lock_path here, display deprecation warning and override the value from
    # the base class.  This preserves the behavior of before lock_path was deprecated.

    warning('The lock_path parameter is deprecated.  Use the lock_path parameter on the base neutron class instead.')

    Neutron_config <| title == 'DEFAULT/lock_path' |> {
      value  => $lock_path,
    }
  }

  neutron_config { 'qos/notification_drivers': value => join(any2array($qos_notification_drivers), ',') }

  if ($::neutron::params::server_package) {
    Package['neutron-server'] -> Neutron_api_config<||>
    Package['neutron-server'] -> Neutron_config<||>
    Package['neutron-server'] -> Service['neutron-server']
    Package['neutron-server'] -> Class['neutron::policy']
    package { 'neutron-server':
      ensure => $package_ensure,
      name   => $::neutron::params::server_package,
      tag    => ['openstack', 'neutron-package'],
    }
  } else {
    # Some platforms (RedHat) does not provide a neutron-server package.
    # The neutron api config file is provided by the neutron package.
    Package['neutron'] -> Class['neutron::policy']
    Package['neutron'] -> Neutron_api_config<||>
  }

  neutron_config {
    'DEFAULT/auth_type': value => $auth_type;
  }

  if ($auth_type == 'keystone') {

    if ($auth_password == false) and ($password == false) {
      fail('Either auth_password or password must be set when using keystone authentication.')
    } elsif ($auth_password != false) and ($password != false) {
      fail('auth_password and password must not be used together.')
    } else {
      neutron_config {
        'keystone_authtoken/auth_uri':     value => $auth_uri;
      }
      neutron_api_config {
        'filter:authtoken/auth_uri':     value => $auth_uri;
      }
    }

    if $auth_password {

      warning('identity_uri, auth_tenant, auth_user, auth_password, auth_region configuration options are deprecated in favor of auth_plugin and related options')
      neutron_config {
        'keystone_authtoken/admin_tenant_name': value => $auth_tenant;
        'keystone_authtoken/admin_user':        value => $auth_user;
        'keystone_authtoken/admin_password':    value => $auth_password, secret => true;
        'keystone_authtoken/auth_region':       value => $auth_region;
        'keystone_authtoken/identity_uri':      value => $identity_uri;
      }

      neutron_api_config {
        'filter:authtoken/admin_tenant_name': value => $auth_tenant;
        'filter:authtoken/admin_user':        value => $auth_user;
        'filter:authtoken/admin_password':    value => $auth_password, secret => true;
        'filter:authtoken/identity_uri':      value => $identity_uri;
      }

    } else {

      neutron_config {
        'keystone_authtoken/auth_url':          value => $auth_url;
        'keystone_authtoken/auth_plugin':       value => $auth_plugin;
        'keystone_authtoken/tenant_name':       value => $tenant_name;
        'keystone_authtoken/username':          value => $username;
        'keystone_authtoken/password':          value => $password, secret => true;
        'keystone_authtoken/region_name':       value => $region_name;
        'keystone_authtoken/project_domain_id': value => $project_domain_id;
        'keystone_authtoken/project_name':      value => $project_name;
        'keystone_authtoken/user_domain_id':    value => $user_domain_id;

      }
    }

  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'neutron-server':
    ensure     => $service_ensure,
    name       => $service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['neutron'],
    tag        => ['neutron-service', 'neutron-db-sync-service'],
  }
}
