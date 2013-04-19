class quantum::agents::l3 (
  $package_ensure               = 'present',
  $enabled                      = true,
  $debug                        = 'False',
  $auth_tenant                  = 'services',
  $auth_user                    = 'quantum',
  $auth_password                = 'password',
  $external_network_bridge      = 'br-ex',
  $use_namespaces               = 'True',
  $interface_driver             = 'quantum.agent.linux.interface.OVSInterfaceDriver',
  $router_id                    = '7e5c2aca-bbac-44dd-814d-f2ea9a4003e4',
  $gateway_external_net_id      = '3f8699d7-f221-421a-acf5-e41e88cfd54f',
  $handle_internal_only_routers = 'True',
  $metadata_ip                  = '127.0.0.1',
  $polling_interval             = 3,
  $root_helper      = 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf',
) {

  include 'quantum::params'

  Quantum_config<||> ~> Service['quantum-l3']
  Quantum_l3_agent_config<||> ~> Service['quantum-l3']

  # The L3 agent loads both quantum.ini and its own file.
  # This only lists config specific to the l3 agent.  quantum.ini supplies
  # the rest.
  quantum_l3_agent_config {
    'DEFAULT/debug':                          value => $debug;
    'DEFAULT/admin_tenant_name':              value => $auth_tenant;
    'DEFAULT/admin_user':                     value => $auth_user;
    'DEFAULT/admin_password':                 value => $auth_password;
    'DEFAULT/use_namespaces':                 value => $use_namespaces;
    'DEFAULT/root_helper':                    value => $root_helper;
    'DEFAULT/interface_driver':               value => $interface_driver;
    'DEFAULT/router_id':                      value => $router_id;
    'DEFAULT/gateway_external_net_id':        value => $gateway_external_net_id;
    'DEFAULT/metadata_ip':                    value => $metadata_ip;
    'DEFAULT/external_network_bridge':        value => $external_network_bridge;
    'DEFAULT/polling_interval':               value => $polling_interval;
  }

  if $::quantum::params::l3_agent_package {
    Package['quantum-l3'] -> Quantum_l3_agent_config<||>
    Package['quantum-l3'] -> Service['quantum-l3']
    package { 'quantum-l3':
      name    => $::quantum::params::l3_agent_package,
      ensure  => $package_ensure,
      require => Package['quantum'],
    }
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-l3':
    name    => $::quantum::params::l3_agent_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }
}
