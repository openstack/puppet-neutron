# == Class: neutron::agents::l2gw
#
# Installs and configures the Neutron L2gw service
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
# [*debug*]
#   (optional) Print debug info in logs
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_hosts*]
#   (optional) OVSDB server tuples in the format
#   Example: ovsdb_hosts = 'ovsdb1:16.95.16.1:6632,ovsdb2:16.95.16.2:6632'
#   Defaults to $facts['os_service_default']
#
# [*enable_manager*]
#   (optional) connection can be initiated by the ovsdb server.
#   Defaults to $facts['os_service_default']
#
# [*manager_table_listening_port*]
#   (optional) set port number for l2gateway agent, so that it can listen
#   Defaults to $facts['os_service_default']
#
# [*l2_gw_agent_priv_key_base_path*]
#   (optional) Base path to private key file(s).
#   Defaults to $facts['os_service_default']
#
# [*l2_gw_agent_cert_base_path*]
#   (optional) Base path to cert file(s).
#   Defaults to $facts['os_service_default']
#
# [*l2_gw_agent_ca_cert_base_path*]
#   (optional) Base path to ca cert file(s).
#   Defaults to $facts['os_service_default']
#
# [*periodic_interval*]
#   (optional) The L2 gateway agent checks connection state with the OVSDB
#   servers. The interval is number of seconds between attempts.
#   Defaults to $facts['os_service_default']
#
# [*max_connection_retries*]
#   (optional) The L2 gateway agent retries to connect to the OVSDB server
#   Defaults to $facts['os_service_default']
#
# [*socket_timeout*]
#   (optional) socket timeout
#   Defaults to $facts['os_service_default']
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the l2gateway config.
#   Default to false.
#
class neutron::agents::l2gw (
  $package_ensure                   = 'present',
  Boolean $enabled                  = true,
  Boolean $manage_service           = true,
  $debug                            = $facts['os_service_default'],
  $ovsdb_hosts                      = $facts['os_service_default'],
  $enable_manager                   = $facts['os_service_default'],
  $manager_table_listening_port     = $facts['os_service_default'],
  $l2_gw_agent_priv_key_base_path   = $facts['os_service_default'],
  $l2_gw_agent_cert_base_path       = $facts['os_service_default'],
  $l2_gw_agent_ca_cert_base_path    = $facts['os_service_default'],
  $periodic_interval                = $facts['os_service_default'],
  $max_connection_retries           = $facts['os_service_default'],
  $socket_timeout                   = $facts['os_service_default'],
  Boolean $purge_config             = false,
) {
  include neutron::deps
  include neutron::params

  resources { 'neutron_l2gw_agent_config':
    purge => $purge_config,
  }

  neutron_l2gw_agent_config {
    'DEFAULT/debug':                            value => $debug;
    'ovsdb/ovsdb_hosts':                        value => join(any2array($ovsdb_hosts), ',');
    'ovsdb/enable_manager':                     value => $enable_manager;
    'ovsdb/manager_table_listening_port':       value => $manager_table_listening_port;
    'ovsdb/l2_gw_agent_priv_key_base_path':     value => $l2_gw_agent_priv_key_base_path;
    'ovsdb/l2_gw_agent_cert_base_path':         value => $l2_gw_agent_cert_base_path;
    'ovsdb/l2_gw_agent_ca_cert_base_path':      value => $l2_gw_agent_ca_cert_base_path;
    'ovsdb/max_connection_retries':             value => $max_connection_retries;
    'ovsdb/socket_timeout':                     value => $socket_timeout;
    'ovsdb/periodic_interval':                  value => $periodic_interval;
  }

  if $neutron::params::l2gw_agent_package {
    package { 'neutron-l2gw-agent':
      ensure => $package_ensure,
      name   => $neutron::params::l2gw_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-l2gw-agent':
      ensure => $service_ensure,
      name   => $neutron::params::l2gw_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
    Neutron_l2gw_agent_config<||> ~> Service['neutron-l2gw-agent']
  }
}
