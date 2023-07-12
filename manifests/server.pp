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
# [*sync_db*]
#   (Optional) Run neutron-db-manage on api nodes after installing the package.
#   Defaults to false
#
# [*api_workers*]
#   (Optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to: $facts['os_workers']
#
# [*rpc_workers*]
#   (Optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to: $facts['os_workers']
#
# [*rpc_state_report_workers*]
#   (Optional) Number of RPC worker process dedicated to state reports queue.
#   Defaults to: $facts['os_service_default'].
#
# [*rpc_response_max_timeout*]
#   (Optional) Maximum seconds to wait for a response from an RPC call
#   Defaults to: $facts['os_service_default']
#
# [*agent_down_time*]
#   (Optional) Seconds to regard the agent as down; should be at least twice
#   report_interval, to be sure the agent is down for good.
#   agent_down_time is a config for neutron-server, set by class neutron::server
#   report_interval is a config for neutron agents, set by class neutron
#   Defaults to: $facts['os_service_default']
#
# [*enable_new_agents*]
#   (Optional) Agent starts with admin_state_up=False when enable_new_agents=False. In the
#   case, user's resources will not be scheduled automatically to the agent until
#   admin changes admin_state_up to True.
#   Defaults to: $facts['os_service_default']
#
# [*network_scheduler_driver*]
#   (Optional) The scheduler used when scheduling networks
#   neutron.scheduler.dhcp_agent_scheduler.AZAwareWeightScheduler to use availability zone hints scheduling.
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
#
# [*enable_dvr*]
#   (Optional) Setting the "enable_dvr" flag to "False" will disable "dvr" API extension exposure.
#   Defaults to $facts['os_service_default']
#
# [*dhcp_load_type*]
#   (Optional) The resource type whose load is being reported by the agent.
#   The expected values are either 'networks', 'subnets', 'ports'.
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
#
# [*allow_automatic_dhcp_failover*]
#   (Optional) Allow automatic rescheduling of dhcp from dead dhcp agents with
#   admin_state_up set to True to alive agents.
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
#
# [*l3_ha_network_type*]
#   (Optional) The network type to use when creating the HA network for an HA
#   router.
#   Defaults to $facts['os_service_default']
#
# [*l3_ha_network_physical_name*]
#   (Optional) The physical network name with which the HA network can be
#   created.
#   Defaults to $facts['os_service_default']
#
# [*network_auto_schedule*]
#   (Optional) Allow auto scheduling networks to DHCP agent
#   Defaults to $facts['os_service_default'].
#
# [*ensure_vpnaas_package*]
#   (Optional) Ensures installation of VPNaaS package before starting API service.
#   Set to true to ensure installation of the package that is required to start neutron service if service_plugin is enabled.
#   Defaults to false.
#
# [*ensure_dr_package*]
#   (Optional) Ensures installation of Neutron Dynamic Routing package before starting API service.
#   Set to true to ensure installation of the package that is required to start neutron service if bgp service_plugin is enabled.
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
#   Defaults to $facts['os_service_default']
#
#   Example:
#
#   class { 'neutron::server':
#     service_providers => [
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
#   Defaults to $facts['os_service_default'].
#
# [*max_request_body_size*]
#   (Optional) Set max request body size
#   Defaults to $facts['os_service_default'].
#
# [*ovs_integration_bridge*]
#   (Optional) Name of Open vSwitch bridge to use
#   Defaults to $facts['os_service_default']
#
# [*igmp_snooping_enable*]
#   (Optional) Enable IGMP snooping for integration bridge. If this
#   option is set to True, support for Internet Group Management
#   Protocol (IGMP) is enabled in integration bridge.
#   Setting this option to True will also enable Open vSwitch
#   mcast-snooping-disable-flood-unregistered flag. This option will
#   disable flooding of unregistered multicast packets to all ports.
#   The switch will send unregistered multicast packets only to ports
#   connected to multicast routers. This option is used by the ML2/OVN
#   mechanism driver for Neutron.
#   Defaults to $facts['os_service_default']
#
class neutron::server (
  $package_ensure                   = 'present',
  Boolean $enabled                  = true,
  Boolean $manage_service           = true,
  $service_name                     = $::neutron::params::server_service,
  $server_package                   = $::neutron::params::server_package,
  $api_package_name                 = $::neutron::params::api_package_name,
  $api_service_name                 = $::neutron::params::api_service_name,
  $rpc_package_name                 = $::neutron::params::rpc_package_name,
  $rpc_service_name                 = $::neutron::params::rpc_service_name,
  Boolean $sync_db                  = false,
  $api_workers                      = $facts['os_workers'],
  $rpc_workers                      = $facts['os_workers'],
  $rpc_state_report_workers         = $facts['os_service_default'],
  $rpc_response_max_timeout         = $facts['os_service_default'],
  $agent_down_time                  = $facts['os_service_default'],
  $enable_new_agents                = $facts['os_service_default'],
  $router_scheduler_driver          = 'neutron.scheduler.l3_agent_scheduler.ChanceScheduler',
  $router_distributed               = $facts['os_service_default'],
  $enable_dvr                       = $facts['os_service_default'],
  $network_scheduler_driver         = $facts['os_service_default'],
  $dhcp_load_type                   = $facts['os_service_default'],
  $default_availability_zones       = $facts['os_service_default'],
  $allow_automatic_l3agent_failover = $facts['os_service_default'],
  $allow_automatic_dhcp_failover    = $facts['os_service_default'],
  $l3_ha                            = $facts['os_service_default'],
  $max_l3_agents_per_router         = $facts['os_service_default'],
  $l3_ha_net_cidr                   = $facts['os_service_default'],
  $l3_ha_network_type               = $facts['os_service_default'],
  $l3_ha_network_physical_name      = $facts['os_service_default'],
  $network_auto_schedule            = $facts['os_service_default'],
  Boolean $ensure_vpnaas_package    = false,
  Boolean $ensure_dr_package        = false,
  $vpnaas_agent_package             = false,
  $service_providers                = $facts['os_service_default'],
  $auth_strategy                    = 'keystone',
  $enable_proxy_headers_parsing     = $facts['os_service_default'],
  $max_request_body_size            = $facts['os_service_default'],
  $ovs_integration_bridge           = $facts['os_service_default'],
  $igmp_snooping_enable             = $facts['os_service_default'],
) inherits neutron::params {

  include neutron::deps
  include neutron::db
  include neutron::policy

  if !is_service_default($default_availability_zones) {
    validate_legacy(Array, 'validate_array', $default_availability_zones)
  }

  if !is_service_default($dhcp_load_type) {
    validate_legacy(Enum['networks', 'subnets', 'ports'], 'validate_re', $dhcp_load_type,
      [['^networks$', '^subnets$', '^ports$']])
  }

  if !is_service_default($service_providers) {
    validate_legacy(Array, 'validate_array', $service_providers)
  }

  if $ensure_vpnaas_package {
    ensure_packages( 'neutron-vpnaas-agent', {
      'ensure' => $package_ensure,
      'name'   => $::neutron::params::vpnaas_agent_package,
      'tag'    => ['openstack', 'neutron-package'],
    })
  }

  if $ensure_dr_package {
    ensure_packages('neutron-dynamic-routing', {
      ensure => $package_ensure,
      name   => $::neutron::params::dynamic_routing_package,
      tag    => ['openstack', 'neutron-package'],
    })
  }

  if $sync_db {
    include neutron::db::sync
  }

  neutron_config {
    'DEFAULT/l3_ha':                            value => $l3_ha;
    'DEFAULT/max_l3_agents_per_router':         value => $max_l3_agents_per_router;
    'DEFAULT/l3_ha_net_cidr':                   value => $l3_ha_net_cidr;
    'DEFAULT/l3_ha_network_type':               value => $l3_ha_network_type;
    'DEFAULT/l3_ha_network_physical_name':      value => $l3_ha_network_physical_name;
    'DEFAULT/api_workers':                      value => $api_workers;
    'DEFAULT/rpc_workers':                      value => $rpc_workers;
    'DEFAULT/rpc_state_report_workers':         value => $rpc_state_report_workers;
    'DEFAULT/rpc_response_max_timeout':         value => $rpc_response_max_timeout;
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
    'ovs/integration_bridge':                   value => $ovs_integration_bridge;
    'service_providers/service_provider':       value => $service_providers;
    'ovs/igmp_snooping_enable':                 value => $igmp_snooping_enable;
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
    include neutron::keystone::authtoken
  }

  oslo::middleware { 'neutron_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
    max_request_body_size        => $max_request_body_size,
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
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
        fail('Use api_service_name and rpc_service_name to run api service by httpd')
      } else {
        warning('Support for arbitrary service name is deprecated')
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
      if $::neutron::params::server_service {
        # we need to make sure neutron-server is stopped before trying to
        # start separate services.
        service { 'neutron-server':
          ensure     => 'stopped',
          name       => $::neutron::params::server_service,
          enable     => false,
          hasstatus  => true,
          hasrestart => true,
          tag        => ['neutron-service'],
        }
      }

      if $api_service_name {
        if $api_service_name == 'httpd' {
          Service <| title == 'httpd' |> { tag +> 'neutron-service' }

          if $::neutron::params::server_service {
            Service['neutron-server'] -> Service['httpd']
          }

          if $::neutron::params::api_service_name {
            # we need to make sure api service is stopped before trying to
            # start apache
            service { 'neutron-api':
              ensure     => 'stopped',
              name       => $::neutron::params::api_service_name,
              enable     => false,
              hasstatus  => true,
              hasrestart => true,
              tag        => ['neutron-service'],
            }
            Service['neutron-api'] -> Service['httpd']
          }
        } else {
          service { 'neutron-api':
            ensure     => $service_ensure,
            name       => $api_service_name,
            enable     => $enabled,
            hasstatus  => true,
            hasrestart => true,
            tag        => ['neutron-service', 'neutron-db-sync-service', 'neutron-server-eventlet'],
          }

          if $::neutron::params::server_service {
            Service['neutron-server'] -> Service['neutron-api']
          }
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

        if $::neutron::params::server_service {
          Service['neutron-server'] -> Service['neutron-rpc-server']
        }
      }
    }
  }
}
