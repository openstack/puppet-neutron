class quantum::agents::l3 (
  $package_ensure               = 'present',
  $enabled                      = true,

  $debug                        = 'False',
  $interface_driver             = 'quantum.agent.linux.interface.OVSInterfaceDriver',
  $auth_url                     = 'http://localhost:5000/v2.0',
  $auth_region                  = 'RegionOne',
  $auth_tenant                  = 'service',
  $auth_user                    = 'quantum',
  $auth_password                = 'password',
  $root_helper                  = 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf',
  $use_namespaces               = 'True',
  $router_id                    = '7e5c2aca-bbac-44dd-814d-f2ea9a4003e4',
  $gateway_external_net_id      = '3f8699d7-f221-421a-acf5-e41e88cfd54f',
  $handle_internal_only_routers = 'True',
  $external_network_bridge      = 'br-ex',
  $metadata_ip                  = '169.254.169.254',
  $metadata_port                = 8775,
  $polling_interval             = 3
) {
  include 'quantum::params'

  Package['quantum'] -> Package['quantum-l3-agent']
  Package['quantum-l3-agent'] -> Quantum_l3_agent_config<||>
  Quantum_config<||> ~> Service['quantum-l3']
  Quantum_l3_agent_config<||> ~> Service['quantum-l3']

  quantum_l3_agent_config {
    'DEFAULT/debug':                          value => $debug;
    'DEFAULT/interface_driver':               value => $interface_driver;
    'DEFAULT/auth_url':                       value => $auth_url;
    'DEFAULT/auth_region':                    value => $auth_region;
    'DEFAULT/auth_tenant':                    value => $auth_tenant;
    'DEFAULT/auth_user':                      value => $auth_user;
    'DEFAULT/auth_password':                  value => $auth_password;
    'DEFAULT/root_helper':                    value => $root_helper;
    'DEFAULT/use_namespaces':                 value => $use_namespaces;
    'DEFAULT/router_id':                      value => $router_id;
    'DEFAULT/gateway_external_net_id':        value => $gateway_external_net_id;
    'DEFAULT/handle_internal_only_routers':   value => $handle_internal_only_routers;
    'DEFAULT/external_network_bridge':        value => $external_network_bridge;
    'DEFAULT/metadata_ip':                    value => $metadata_ip;
    'DEFAULT/metadata_port':                  value => $metadata_port;
    'DEFAULT/polling_interval':               value => $polling_interval;
  }

  package { 'quantum-l3':
    name    => $::quantum::params::l3_package,
    ensure  => $package_ensure,
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-l3':
    name    => $::quantum::params::l3_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => [Package[$::quantum::params::l3_package], Class['quantum']],
  }
}
