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
# [*database_connection*]
#   (optional) Connection url for the neutron database.
#   (Defaults to undef)
#
# [*memcached_servers*]
#   (optinal) a list of memcached server(s) to use for caching. If left
#   undefined, tokens will instead be cached in-process.
#   Defaults to $::os_service_default.
#
# [*database_max_retries*]
#   (optional) Maximum database connection retries during startup.
#   (Defaults to undef)
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle database connections are reaped.
#   Deprecates sql_idle_timeout
#   (Defaults to undef)
#
# [*database_retry_interval*]
#   (optional) Interval between retries of opening a database connection.
#   (Defaults to 10)
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
# [*enable_new_agents*]
#   (optional) Agent starts with admin_state_up=False when enable_new_agents=False. In the
#   case, user's resources will not be scheduled automatically to the agent until
#   admin changes admin_state_up to True.
#   Defaults to: $::os_service_default
#
# [*state_path*]
#   (optional) Deprecated.  Use state_path parameter on base neutron class instead.
#
# [*lock_path*]
#   (optional) Deprecated.  Use lock_path parameter on base neutron class instead.
#
# [*network_scheduler_driver*]
#   (optional) The scheduler used when scheduling networks
#   neutron.scheduler.dhcp_agent_scheduler.AZAwareWeightScheduler to use availability zone hints scheduling.
#   Defaults to $::os_service_default
#
#   Example:
#
#     class { 'neutron':
#       network_scheduler_driver => 'neutron.scheduler.dhcp_agent_scheduler.AZAwareWeightScheduler'
#     }
#
# [*router_scheduler_driver*]
#   (optional) Driver to use for scheduling router to a default L3 agent. Could be:
#   neutron.scheduler.l3_agent_scheduler.ChanceScheduler to schedule a router in a random way
#   neutron.scheduler.l3_agent_scheduler.LeastRoutersScheduler to allocate on an L3 agent with the least number of routers bound.
#   neutron.scheduler.l3_agent_scheduler.AZLeastRoutersScheduler to use availability zone hints.
#   Defaults to: neutron.scheduler.l3_agent_scheduler.ChanceScheduler
#
# [*router_distributed*]
#   (optional) Setting the "router_distributed" flag to "True" will default to the creation
#   of distributed tenant routers.
#   Also can be the type of the router on the create request (admin-only attribute).
#   Defaults to $::os_service_default
#
# [*dhcp_load_type*]
#   (optional) The resource type whos load is being reported by the agent.
#   The expected values are either 'networks', 'subnets', 'ports'.
#   Defaults to $::os_service_default
#
#   Example:
#
#     class { 'neutron':
#       dhcp_load_type => 'networks'
#     }
#
# [*default_availability_zones*]
#   (optional) A list of availability zones that are picked when availability zone is not specified
#   The expected input is an array when specified.
#   Defaults to $::os_service_default
#
#   Example:
#
#     class { 'neutron':
#       default_availability_zones => ['zone1', 'zone2']
#     }
#
# [*allow_automatic_l3agent_failover*]
#   (optional) Allow automatic rescheduling of routers from dead L3 agents with
#   admin_state_up set to True to alive agents.
#   Defaults to $::os_service_default
#
# [*allow_automatic_dhcp_failover*]
#   (optional) Allow automatic rescheduling of dhcp from dead dhcp agents with
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
# [*network_auto_schedule*]
#   (optional) Allow auto scheduling networks to DHCP agent
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
# [*vpnaas_agent_package*]
#   (optional) Use VPNaaS agent package instead of L3 agent package on debian platforms
#   RedHat platforms won't take care of this parameter
#   true/false
#   Defaults to false
#
# [*service_providers*]
#   (optional) (Array) Configures the service providers for neutron server.
#   This needs to be set for lbaas, vpnaas, and fwaas.
#   Defaults to $::os_service_default
#
#   Example:
#
#   class { 'neutron::server':
#     service_providers => [
#        'LOADBALANCERV2:Octavia:neutron_lbaas.drivers.octavia.driver.OctaviaDriver:default',
#        'LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver',
#        'VPN:openswan:neutron_vpnaas.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default'
#     ]
#   }
#
# [*auth_strategy*]
#   (optional) The strategy to use for authentication.
#   Defaults to 'keystone'
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
# === Deprecated Parameters
#
# [*ensure_lbaas_package*]
#   Deprecated. Ensures installation of LBaaS package.
#   LBaaS agent should be installed from neutron::agents::lbaas.
#   Defaults to false.
#
# [*min_l3_agents_per_router*]
#   Deprecated. (optional) Minimum number of l3 agents which a HA router will be scheduled on.
#   Defaults to undef
#
# [*keystone_auth_type*]
#   (optional) Deprecated Use neutron::keystone::authtoken::auth_type instead.
#   Defaults to undef
#
# [*auth_uri*]
#   (optional) Deprecated Use neutron::keystone::authtoken::auth_uri
#   Defaults to undef
#
# [*auth_url*]
#   (optional) Deprecated Use neutron::keystone::authtoken::auth_url instead
#   Defaults to undef
#
# [*username*]
#   (optional) Deprecated Use neutron::keystone::authtoken::username instead
#   Defaults to undef
#
# [*password*]
#   (optional) Deprecated Use neutron::keystone::authtoken::password
#   Defaults to undef
#
# [*project_domain_id*]
#   Deprecated. Auth user project's domain ID
#   Defaults to $::os_service_default
#
# [*project_domain_name*]
#   (optional) Deprecated
#   Use neutron::keystone::authtoken::project_domain_name instead
#   Defaults to undef
#
# [*project_name*]
#   (optional) Deprecated Use neutron::keystone::authtoken::project_name
#   instead
#   Defaults to undef
#
# [*user_domain_id*]
#   (optional) Deprecated Use neutron::keystone::authtoken::
#   Defaults to $::os_service_default
#
# [*user_domain_name*]
#   (optional) Deprecated Use neutron::keystone::authtoken::user_domain_name
#   instead
#   Defaults to undef
#
# [*region_name*]
#   (optional) Deprecated Use neutron::keystone::authtoken::region_name
#   instead.
#   Defaults to undef
#
# [*memcached_servers*]
#   (optional) Deprecated Use neutron::keystone::authtoken::memcached_servers
#   instead
#   Defaults to undef
#
# [*auth_type*]
#   (optional) Deprecated Use auth_strategy instead.
#   Defaults to undef
#
class neutron::server (
  $package_ensure                   = 'present',
  $enabled                          = true,
  $manage_service                   = true,
  $service_name                     = $::neutron::params::server_service,
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
  $enable_new_agents                = $::os_service_default,
  $router_scheduler_driver          = 'neutron.scheduler.l3_agent_scheduler.ChanceScheduler',
  $router_distributed               = $::os_service_default,
  $network_scheduler_driver         = $::os_service_default,
  $dhcp_load_type                   = $::os_service_default,
  $default_availability_zones       = $::os_service_default,
  $allow_automatic_l3agent_failover = $::os_service_default,
  $allow_automatic_dhcp_failover    = $::os_service_default,
  $l3_ha                            = false,
  $max_l3_agents_per_router         = 3,
  $l3_ha_net_cidr                   = $::os_service_default,
  $qos_notification_drivers         = $::os_service_default,
  $network_auto_schedule            = $::os_service_default,
  $ensure_vpnaas_package            = false,
  $ensure_fwaas_package             = false,
  $vpnaas_agent_package             = false,
  $service_providers                = $::os_service_default,
  $auth_strategy                    = 'keystone',
  $enable_proxy_headers_parsing     = $::os_service_default,
  # DEPRECATED PARAMETERS
  $log_dir                          = undef,
  $log_file                         = undef,
  $report_interval                  = undef,
  $state_path                       = undef,
  $lock_path                        = undef,
  $ensure_lbaas_package             = false,
  $min_l3_agents_per_router         = undef,
  $keystone_auth_type               = undef,
  $auth_uri                         = undef,
  $auth_url                         = undef,
  $username                         = undef,
  $password                         = undef,
  $region_name                      = undef,
  $project_domain_name              = undef,
  $project_name                     = undef,
  $user_domain_name                 = undef,
  $memcached_servers                = undef,
  $project_domain_id                = $::os_service_default,
  $user_domain_id                   = $::os_service_default,
  $auth_type                        = undef,
) inherits ::neutron::params {

  include ::neutron::deps
  include ::neutron::db
  include ::neutron::policy
  # Work-around LP#1551974. neutron requires the keystoneclient to auth tokens
  include ::keystone::client

  if $auth_type {
    warning('neutron::server::auth_type is deprecated, use neutron::server::auth_strategy instead.')
  }

  if $keystone_auth_type {
    warning('neutron::server::keystone_auth_type is deprecated, use neutron::keystone::authtoken::auth_type instead.')
  }

  if $auth_uri {
    warning('neutron::server::auth_uri is deprecated, use neutron::keystone::authtoken::auth_uri instead.')
  }

  if $auth_url {
    warning('neutron::server::auth_url is deprecated, use neutron::keystone::authtoken::auth_url instead.')
  }

  if $username {
    warning('neutron::server::username is deprecated, use neutron::keystone::authtoken::username instead.')
  }

  if $password {
    warning('neutron::server::password is deprecated, use neutron::keystone::authtoken::password instead.')
  }

  if ! is_service_default($project_domain_id) {
    warning('neutron::server::project_domain_id is deprecated, use neutron::keystone::authtoken::project_domain_name instead.')
  }

  if $project_domain_name {
    warning('neutron::server::project_domain_name is deprecated, use neutron::keystone::authtoken::project_domain_name instead.')
  }

  if $project_name {
    warning('neutron::server::project_name is deprecated, use neutron::keystone::authtoken::project_name instead.')
  }

  if ! is_service_default($user_domain_id) {
    warning('neutron::server::user_domain_id is deprecated, use neutron::keystone::authtoken::user_domain_name instead.')
  }

  if $user_domain_name {
    warning('neutron::server::user_domain_name is deprecated, use neutron::keystone::authtoken::user_domain_name instead.')
  }

  if $region_name {
    warning('neutron::server::region_name is deprecated, use neutron::keystone::authtoken::region_name instead.')
  }

  if $memcached_servers {
    warning('neutron::server::memcached_servers is deprecated, use neutron::keystone::authtoken::memcached_servers instead')
  }

  if !is_service_default($default_availability_zones) {
    validate_array($default_availability_zones)
  }

  if !is_service_default($dhcp_load_type) {
    validate_re($dhcp_load_type,
                ['^networks$', '^subnets$', '^ports$'],
                'Must pass either networks, subnets, or ports as values for dhcp_load_type')
  }

  if !is_service_default($service_providers) {
    validate_array($service_providers)
  }

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
    warning('$ensure_lbaas_package is deprecated. To install lbaas agent the neutron::agents::lbaas class should be used.')
    ensure_resource( 'package', 'neutron-lbaasv2-agent', {
      'ensure' => $package_ensure,
      'name'   => $::neutron::params::lbaasv2_agent_package,
      'tag'    => ['openstack', 'neutron-package'],
    })
  }

  if $sync_db {
    include ::neutron::db::sync
  }

  if $min_l3_agents_per_router {
    warning('min_l3_agents_per_router is deprecated, has no effect and will be removed for the Ocata release.')
  }

  neutron_config {
    'DEFAULT/l3_ha':                            value => $l3_ha;
    'DEFAULT/max_l3_agents_per_router':         value => $max_l3_agents_per_router;
    'DEFAULT/l3_ha_net_cidr':                   value => $l3_ha_net_cidr;
    'DEFAULT/api_workers':                      value => $api_workers;
    'DEFAULT/rpc_workers':                      value => $rpc_workers;
    'DEFAULT/agent_down_time':                  value => $agent_down_time;
    'DEFAULT/enable_new_agents':                value => $enable_new_agents;
    'DEFAULT/router_scheduler_driver':          value => $router_scheduler_driver;
    'DEFAULT/router_distributed':               value => $router_distributed;
    'DEFAULT/allow_automatic_l3agent_failover': value => $allow_automatic_l3agent_failover;
    'DEFAULT/allow_automatic_dhcp_failover':    value => $allow_automatic_dhcp_failover;
    'DEFAULT/network_scheduler_driver':         value => $network_scheduler_driver;
    'DEFAULT/dhcp_load_type':                   value => $dhcp_load_type;
    'DEFAULT/default_availability_zones':       value => join(any2array($default_availability_zones), ',');
    'DEFAULT/network_auto_schedule':            value => $network_auto_schedule;
    'service_providers/service_provider':       value => $service_providers;
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

    Neutron_config <| title == 'oslo_concurrency/lock_path' |> {
      value  => $lock_path,
    }
  }

  neutron_config { 'qos/notification_drivers': value => join(any2array($qos_notification_drivers), ',') }

  if ($::neutron::params::server_package) {
    package { 'neutron-server':
      ensure => $package_ensure,
      name   => $::neutron::params::server_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  neutron_config {
    'DEFAULT/auth_type': value => $auth_type;
  }

  $auth_strategy_real = pick($auth_type, $auth_strategy)
  if ($auth_strategy_real == 'keystone') {

    include ::neutron::keystone::authtoken

    neutron_api_config {
      'filter:authtoken/admin_tenant_name':   ensure => absent;
      'filter:authtoken/admin_user':          ensure => absent;
      'filter:authtoken/admin_password':      ensure => absent;
      'filter:authtoken/identity_uri':        ensure => absent;
    }

  }

  oslo::middleware { 'neutron_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
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
    tag        => ['neutron-service', 'neutron-db-sync-service'],
  }
}
