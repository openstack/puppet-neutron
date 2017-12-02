# == Class: neutron::agents::ovn_metadata
#
# Setup and configure networking-ovn metadata agent.
#
# === Parameters
#
# [*shared_secret*]
#   (required) Shared secret to validate proxies Neutron metadata requests.
#
# [*package_ensure*]
#   Ensure state of the package. Defaults to 'present'.
#
# [*enabled*]
#   State of the service. Defaults to true.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   Debug. Defaults to false.
#
# [*auth_ca_cert*]
#   CA cert to check against with for ssl keystone. (Defaults to $::os_service_default)
#
# [*nova_client_cert*]
#   Client certificate for nova metadata api server. (Defaults to $::os_service_default)
#
# [*nova_client_priv_key*]
#   Private key of client certificate. (Defaults to $::os_service_default)
#
# [*metadata_ip*]
#   The IP address of the metadata service. Defaults to $::os_service_default.
#
# [*metadata_host*]
#   The hostname of the metadata service. Defaults to $::os_service_default.
#
# [*metadata_port*]
#   The TCP port of the metadata service. Defaults to $::os_service_default.
#
# [*metadata_protocol*]
#   The protocol to use for requests to Nova metadata server. Defaults to $::os_service_default.
#
# [*metadata_workers*]
#   (optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to: $::os_workers
#
# [*metadata_backlog*]
#   (optional) Number of backlog requests to configure the metadata server socket with.
#   Defaults to $::os_service_default
#
# [*metadata_insecure*]
#   (optional) Allow to perform insecure SSL (https) requests to nova metadata.
#   Defaults to $::os_service_default
#
# [*ovsdb_connection*]
#   (optional) The URI used to connect to the local OVSDB server.
#   Defaults to 'tcp:127.0.0.1:6640'
#
# [*ovs_manager*]
#   The manager target that will be set to OVS so that the metadata agent can
#   connect to.
#   Defaults to 'ptcp:6640:127.0.0.1'
#
# [*ovn_sb_connection*]
#   (optional) The connection string for the OVN_Southbound OVSDB
#   Defaults to '$::os_service_default'
#
# [*ovsdb_connection_timeout*]
#   (optional) Timeout in seconds for the OVSDB connection transaction
#   Defaults to $::os_service_default
#
# [*root_helper*]
#  (optional) Use "sudo neutron-rootwrap /etc/neutron/rootwrap.conf" to use the real
#  root filter facility. Change to "sudo" to skip the filtering and just run the command
#  directly
#  Defaults to 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf'.
#
# [*root_helper_daemon*]
#  (optional) Root helper daemon application to use when possible.
#  Defaults to $::os_service_default.
#
# [*state_path*]
#   (optional) Where to store state files. This directory must be writable
#   by the user executing the agent
#   Defaults to: '/var/lib/neutron'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the metadata config.
#   Defaults to false.

class neutron::agents::ovn_metadata (
  $shared_secret,
  $package_ensure            = 'present',
  $enabled                   = true,
  $manage_service            = true,
  $debug                     = false,
  $auth_ca_cert              = $::os_service_default,
  $metadata_ip               = $::os_service_default,
  $metadata_host             = $::os_service_default,
  $metadata_port             = $::os_service_default,
  $metadata_protocol         = $::os_service_default,
  $metadata_workers          = $::os_workers,
  $metadata_backlog          = $::os_service_default,
  $metadata_insecure         = $::os_service_default,
  $nova_client_cert          = $::os_service_default,
  $nova_client_priv_key      = $::os_service_default,
  $ovsdb_connection          = 'tcp:127.0.0.1:6640',
  $ovs_manager               = 'ptcp:6640:127.0.0.1',
  $ovn_sb_connection         = $::os_service_default,
  $ovsdb_connection_timeout  = $::os_service_default,
  $root_helper               = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $root_helper_daemon        = $::os_service_default,
  $state_path                = '/var/lib/neutron',
  $purge_config              = false,
  ) {

  include ::neutron::deps
  include ::neutron::params

  resources { 'ovn_metadata_agent_config':
    purge => $purge_config,
  }

  ovn_metadata_agent_config {
    'DEFAULT/debug':                          value => $debug;
    'DEFAULT/auth_ca_cert':                   value => $auth_ca_cert;
    'DEFAULT/nova_metadata_ip':               value => $metadata_ip;
    'DEFAULT/nova_metadata_host':             value => $metadata_host;
    'DEFAULT/nova_metadata_port':             value => $metadata_port;
    'DEFAULT/nova_metadata_protocol':         value => $metadata_protocol;
    'DEFAULT/nova_metadata_insecure':         value => $metadata_insecure;
    'DEFAULT/metadata_proxy_shared_secret':   value => $shared_secret;
    'DEFAULT/metadata_workers':               value => $metadata_workers;
    'DEFAULT/metadata_backlog':               value => $metadata_backlog;
    'DEFAULT/nova_client_cert':               value => $nova_client_cert;
    'DEFAULT/nova_client_priv_key':           value => $nova_client_priv_key;
    'DEFAULT/state_path':                     value => $state_path;
    'agent/root_helper':                      value => $root_helper;
    'agent/root_helper_daemon':               value => $root_helper_daemon;
    'ovs/ovsdb_connection':                   value => $ovsdb_connection;
    'ovs/ovsdb_connection_timeout':           value => $ovsdb_connection_timeout;
    'ovn/ovn_sb_connection':                  value => $ovn_sb_connection;
  }

  if $::neutron::params::ovn_metadata_agent_package {
    package { 'ovn-metadata':
      ensure => $package_ensure,
      name   => $::neutron::params::ovn_metadata_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'ovn-metadata':
    ensure => $service_ensure,
    name   => $::neutron::params::ovn_metadata_agent_service,
    enable => $enabled,
    tag    => 'neutron-service',
  }

  # Set OVS manager so that metadata agent can connect to Open vSwitch
  exec { 'Set OVS Manager':
    command => "ovs-vsctl --timeout=5 --id=@manager -- create Manager target=\\\"${ovs_manager}\\\" \
               -- add Open_vSwitch . manager_options @manager",
    unless  => "ovs-vsctl show | grep \"${ovs_manager}\"",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    notify  => Service['ovn-metadata'],
  }
}
