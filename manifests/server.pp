# == Class: neutron::server
#
# Setup and configure the neutron API endpoint
#
# === Parameters
#
# [*package_ensure*]
#   (Optional) The state of the package
#   Defaults to present
#
# [*enabled*]
#   (Optional) The state of the service
#   Defaults to true
#
# [*manage_service*]
#   (Optional) Whether to start/stop the service
#   Defaults to true
#
# [*service_name*]
#   (Optional) Name of the service that will be providing the
#   server functionality of neutron-api.
#   If the value is 'httpd', this means neutron API will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'neutron::wsgi::apache'...}
#   to make neutron-api be a web app using apache mod_wsgi.
#   If set to false, then neutron-server isn't in use, and we will
#   be using neutron-api and neutron-rpc-server instead.
#   Defaults to $::neutron::params::server_service
#
# [*server_package*]
#   (Optional) Name of the package holding neutron-server.
#   If service_name is set to false, then this also must be
#   set to false. With false, no package will be installed
#   before running the neutron-server service.
#   Defaults to $::neutron::params::server_package
#
# [*api_package_name*]
#   (Optional) Name of the package holding neutron-api.
#   If this parameter is set to false,
#   Default to $::neutron::params::api_package_name
#
# [*api_service_name*]
#   (Optional) Name of the service for neutron-api.
#   If service_name is set to false, this parameter must
#   be set with a value, so that an API server will run.
#   Defaults to $::neutron::params::api_service_name
#
# [*rpc_package_name*]
#   (Optional) Name of the package for neutron-rpc-server.
#   Default to $::neutron::params::rpc_package_name
#
# [*rpc_service_name*]
#   (Optional) Name of the service for the RPC listener.
#   If service_name is set to false, this parameter must
#   be set with a value, so that an RPC server will run.
#   Defaults to $::neutron::params::rpc_service_name
#
# [*validate*]
#   (Optional) Whether to validate the service is working after any service refreshes
#   Defaults to false
#
# [*database_connection*]
#   (Optional) Connection url for the neutron database.
#   (Defaults to undef)
#
# [*database_max_retries*]
#   (Optional) Maximum database connection retries during startup.
#   (Defaults to undef)
#
# [*database_idle_timeout*]
#   (Optional) Timeout before idle database connections are reaped.
#   (Defaults to undef)
#
# [*database_retry_interval*]
#   (Optional) Interval between retries of opening a database connection.
#   (Defaults to 10)
#
# [*database_min_pool_size*]
#   (Optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to: undef.
#
# [*database_max_pool_size*]
#   (Optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to: undef.
#
# [*database_max_overflow*]
#   (Optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef.
#
# [*sync_db*]
#   (Optional) Run neutron-db-manage on api nodes after installing the package.
#   Defaults to false
#
# [*api_workers*]
#   (Optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to: $::os_workers
#
# [*rpc_workers*]
#   (Optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to: $::os_workers
#
# [*agent_down_time*]
#   (Optional) Seconds to regard the agent as down; should be at least twice
#   report_interval, to be sure the agent is down for good.
#   agent_down_time is a config for neutron-server, set by class neutron::server
#   report_interval is a config for neutron agents, set by class neutron
#   Defaults to: $::os_service_default
#
# [*enable_new_agents*]
#   (Optional) Agent starts with admin_state_up=False when enable_new_agents=False. In the
#   case, user's resources will not be scheduled automatically to the agent until
#   admin changes admin_state_up to True.
#   Defaults to: $::os_service_default
#
# [*network_scheduler_driver*]
#   (Optional) The scheduler used when scheduling networks
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
#   (Optional) Driver to use for scheduling router to a default L3 agent. Could be:
#   neutron.scheduler.l3_agent_scheduler.ChanceScheduler to schedule a router in a random way
#   neutron.scheduler.l3_agent_scheduler.LeastRoutersScheduler to allocate on an L3 agent with the least number of routers bound.
#   neutron.scheduler.l3_agent_scheduler.AZLeastRoutersScheduler to use availability zone hints.
#   Defaults to: neutron.scheduler.l3_agent_scheduler.ChanceScheduler
#
# [*router_distributed*]
#   (Optional) Setting the "router_distributed" flag to "True" will default to the creation
#   of distributed tenant routers.
#   Also can be the type of the router on the create request (admin-only attribute).
#   Defaults to $::os_service_default
#
# [*enable_dvr*]
#   (Optional) Setting the "enable_dvr" flag to "False" will disable "dvr" API extension exposure.
#   Defaults to $::os_service_default
#
# [*dhcp_load_type*]
#   (Optional) The resource type whos load is being reported by the agent.
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
#   (Optional) A list of availability zones that are picked when availability zone is not specified
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
#   (Optional) Allow automatic rescheduling of routers from dead L3 agents with
#   admin_state_up set to True to alive agents.
#   Defaults to $::os_service_default
#
# [*allow_automatic_dhcp_failover*]
#   (Optional) Allow automatic rescheduling of dhcp from dead dhcp agents with
#   admin_state_up set to True to alive agents.
#   Defaults to $::os_service_default
#
# [*l3_ha*]
#   (Optional) Enable high availability for virtual routers.
#   Defaults to false
#
# [*max_l3_agents_per_router*]
#   (Optional) Maximum number of l3 agents which a HA router will be scheduled on. If set to '0', a router will be scheduled on every agent.
#   Defaults to '3'
#
# [*l3_ha_net_cidr*]
#   (Optional) CIDR of the administrative network if HA mode is enabled.
#   Defaults to $::os_service_default
#
# [*network_auto_schedule*]
#   (Optional) Allow auto scheduling networks to DHCP agent
#   Defaults to $::os_service_default.
#
# [*ensure_vpnaas_package*]
#   (Optional) Ensures installation of VPNaaS package before starting API service.
#   Set to true to ensure installation of the package that is required to start neutron service if service_plugin is enabled.
#   Defaults to false.
#
# [*ensure_fwaas_package*]
#   (Optional) Ensures installation of FWaaS package before starting API service.
#   Set to true to ensure installation of the package that is required to start neutron service if service_plugin is enabled.
#   Defaults to false.
#
# [*vpnaas_agent_package*]
#   (Optional) Use VPNaaS agent package instead of L3 agent package on debian platforms
#   RedHat platforms won't take care of this parameter
#   true/false
#   Defaults to false
#
# [*service_providers*]
#   (Optional) (Array) Configures the service providers for neutron server.
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
#   (Optional) The strategy to use for authentication.
#   Defaults to 'keystone'
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
# [*ovs_integration_bridge*]
#   (Optional) Name of Open vSwitch bridge to use
#   Defaults to $::os_service_default
#
class neutron::server (
  $package_ensure                   = 'present',
  $enabled                          = true,
  $manage_service                   = true,
  $service_name                     = $::neutron::params::server_service,
  $server_package                   = $::neutron::params::server_package,
  $api_package_name                 = $::neutron::params::api_package_name,
  $api_service_name                 = $::neutron::params::api_service_name,
  $rpc_package_name                 = $::neutron::params::rpc_package_name,
  $rpc_service_name                 = $::neutron::params::rpc_service_name,
  $validate                         = false,
  $database_connection              = undef,
  $database_max_retries             = undef,
  $database_idle_timeout            = undef,
  $database_retry_interval          = undef,
  $database_min_pool_size           = undef,
  $database_max_pool_size           = undef,
  $database_max_overflow            = undef,
  $sync_db                          = false,
  $api_workers                      = $::os_workers,
  $rpc_workers                      = $::os_workers,
  $agent_down_time                  = $::os_service_default,
  $enable_new_agents                = $::os_service_default,
  $router_scheduler_driver          = 'neutron.scheduler.l3_agent_scheduler.ChanceScheduler',
  $router_distributed               = $::os_service_default,
  $enable_dvr                       = $::os_service_default,
  $network_scheduler_driver         = $::os_service_default,
  $dhcp_load_type                   = $::os_service_default,
  $default_availability_zones       = $::os_service_default,
  $allow_automatic_l3agent_failover = $::os_service_default,
  $allow_automatic_dhcp_failover    = $::os_service_default,
  $l3_ha                            = false,
  $max_l3_agents_per_router         = 3,
  $l3_ha_net_cidr                   = $::os_service_default,
  $network_auto_schedule            = $::os_service_default,
  $ensure_vpnaas_package            = false,
  $ensure_fwaas_package             = false,
  $vpnaas_agent_package             = false,
  $service_providers                = $::os_service_default,
  $auth_strategy                    = 'keystone',
  $enable_proxy_headers_parsing     = $::os_service_default,
  $ovs_integration_bridge           = $::os_service_default,
) inherits ::neutron::params {

  include ::neutron::deps
  include ::neutron::db
  include ::neutron::policy
  # Work-around LP#1551974. neutron requires the keystoneclient to auth tokens
  include ::keystone::client

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

  if $sync_db {
    include ::neutron::db::sync
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
    'DEFAULT/enable_dvr':                       value => $enable_dvr;
    'DEFAULT/allow_automatic_l3agent_failover': value => $allow_automatic_l3agent_failover;
    'DEFAULT/allow_automatic_dhcp_failover':    value => $allow_automatic_dhcp_failover;
    'DEFAULT/network_scheduler_driver':         value => $network_scheduler_driver;
    'DEFAULT/dhcp_load_type':                   value => $dhcp_load_type;
    'DEFAULT/default_availability_zones':       value => join(any2array($default_availability_zones), ',');
    'DEFAULT/network_auto_schedule':            value => $network_auto_schedule;
    'DEFAULT/ovs_integration_bridge':           value => $ovs_integration_bridge;
    'service_providers/service_provider':       value => $service_providers;
  }

  if $server_package {
    package { 'neutron-server':
      ensure => $package_ensure,
      name   => $::neutron::params::server_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $api_package_name {
    package { 'neutron-api':
      ensure => $package_ensure,
      name   => $api_package_name,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $rpc_package_name {
    package { 'neutron-rpc-server':
      ensure => $package_ensure,
      name   => $rpc_package_name,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if ($auth_strategy == 'keystone') {

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

  # $service_name is the old 'neutron-server' service. If it is in use,
  # then we don't need to start neutron-api and neutron-rpc-server. If
  # it is not, then we must start neutron-api and neutron-rpc-server instead.
  if $service_name {
    if $service_name == $::neutron::params::server_service {
      service { 'neutron-server':
        ensure     => $service_ensure,
        name       => $::neutron::params::server_service,
        enable     => $enabled,
        hasstatus  => true,
        hasrestart => true,
        tag        => ['neutron-service', 'neutron-db-sync-service', 'neutron-server-eventlet'],
      }
    } elsif $service_name == 'httpd' {
      include ::apache::params
      service { 'neutron-server':
        ensure     => 'stopped',
        name       => $::neutron::params::server_service,
        enable     => false,
        hasstatus  => true,
        hasrestart => true,
        tag        => ['neutron-service', 'neutron-db-sync-service'],
      }
      Service <| title == 'httpd' |> { tag +> 'neutron-service' }
      # we need to make sure neutron-server is stopped before trying to start apache
      Service[$::neutron::params::server_service] -> Service[$service_name]
    } else {
      # backward compatibility so operators can customize the service name.
      service { 'neutron-server':
        ensure     => $service_ensure,
        name       => $service_name,
        enable     => $enabled,
        hasstatus  => true,
        hasrestart => true,
        tag        => ['neutron-service', 'neutron-db-sync-service'],
      }
    }
  } else {
    if $api_service_name {
      service { 'neutron-server':
        ensure     => $service_ensure,
        name       => $api_service_name,
        enable     => $enabled,
        hasstatus  => true,
        hasrestart => true,
        tag        => ['neutron-service', 'neutron-db-sync-service', 'neutron-server-eventlet'],
      }
    }

    if $rpc_service_name {
      service { 'neutron-rpc-server':
        ensure     => $service_ensure,
        name       => $rpc_service_name,
        enable     => $enabled,
        hasstatus  => true,
        hasrestart => true,
        tag        => ['neutron-service', 'neutron-db-sync-service'],
      }
    }
  }

  # The service validation is required by Debian and Ubuntu, because the
  # server takes too much time to be fully up after the service starts.
  if $validate {
    $keystone_project_name = $::neutron::keystone::authtoken::project_name
    $keystone_username = $::neutron::keystone::authtoken::username
    $keystone_password = $::neutron::keystone::authtoken::password
    $keystone_www_uri = $::neutron::keystone::authtoken::www_authenticate_uri

    $validation_cmd = {
      'neutron-server' => {
        'environment' => ["OS_PASSWORD=${keystone_password}"],
        # lint:ignore:140chars
        'unless'      => "openstack --os-auth-url ${keystone_www_uri} --os-project-name ${keystone_project_name} --os-username ${keystone_username} --os-identity-api-version 3 network list",
        'command'     => "openstack --os-auth-url ${keystone_www_uri} --os-project-name ${keystone_project_name} --os-username ${keystone_username} --os-identity-api-version 3 network list",
        # lint:endignore
        'timeout'     => '60',
        'tries'       => '30',
        'try_sleep'   => '2',
      }
    }
    create_resources('openstacklib::service_validation', $validation_cmd, {'subscribe' => 'Service[neutron-server]'})
  }
}
