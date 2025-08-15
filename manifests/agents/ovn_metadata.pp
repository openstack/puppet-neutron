# == Class: neutron::agents::ovn_metadata
#
# DEPRECATED !!
# Setup and configure neutron ovn metadata agent.
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
#   (optional) Debug. Defaults to $facts['os_service_default'].
#
# [*auth_ca_cert*]
#   (optionall) CA cert to check against with for ssl keystone.
#   Defaults to $facts['os_service_default']
#
# [*nova_client_cert*]
#   (optionall) Client certificate for nova metadata api server.
#   Defaults to $facts['os_service_default']
#
# [*nova_client_priv_key*]
#   (optionall) Private key of client certificate.
#   Defaults to $facts['os_service_default']
#
# [*metadata_host*]
#   (optionall) The hostname of the metadata service.
#   Defaults to $facts['os_service_default']
#
# [*metadata_port*]
#   (optionall) The TCP port of the metadata service.
#   Defaults to $facts['os_service_default']
#
# [*metadata_protocol*]
#   (optionall) The protocol to use for requests to Nova metadata server.
#   Defaults to $facts['os_service_default']
#
# [*metadata_workers*]
#   (optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to: $facts['os_service_defaut']
#
# [*metadata_backlog*]
#   (optional) Number of backlog requests to configure the metadata server
#   socket with.
#   Defaults to $facts['os_service_default']
#
# [*metadata_insecure*]
#   (optional) Allow to perform insecure SSL (https) requests to nova metadata.
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_connection*]
#   (optional) The URI used to connect to the local OVSDB server.
#   Defaults to 'tcp:127.0.0.1:6640'
#
# [*ovs_manager*]
#   (optional) The manager target that will be set to OVS so that the metadata
#   agent can connect to.
#   Defaults to 'ptcp:6640:127.0.0.1'
#
# [*ovn_sb_connection*]
#   (optional) The connection string for the OVN_Southbound OVSDB
#   Defaults to '$facts['os_service_default']'
#
# [*ovn_sb_private_key*]
#   (optional) TThe PEM file with private key for SSL connection to OVN-SB-DB
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_certificate*]
#   (optional) The PEM file with certificate that certifies the
#   private key specified in ovn_sb_private_key
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_ca_cert*]
#   (optional) TThe PEM file with CA certificate that OVN should use to
#   verify certificates presented to it by SSL peers
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_connection_timeout*]
#   (optional) Timeout in seconds for the OVSDB connection transaction
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_retry_max_interval*]
#   (optional) Max interval in seconds between each retry to get the OVN NB
#   and SB IDLs.
#   Defaults to $facts['os_service_default'].
#
# [*ovsdb_probe_interval*]
#   (optional) The probe interval for the OVSDB session in milliseconds.
#   Defaults to $facts['os_service_default'].
#
# [*root_helper*]
#   (optional) Use "sudo neutron-rootwrap /etc/neutron/rootwrap.conf" to use
#   the real root filter facility. Change to "sudo" to skip the filtering and
#   just run the command directly
#   Defaults to 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf'.
#
# [*root_helper_daemon*]
#   (optional) Root helper daemon application to use when possible.
#   Defaults to $facts['os_service_default'].
#
# [*state_path*]
#   (optional) Where to store state files. This directory must be writable
#   by the user executing the agent
#   Defaults to $facts['os_service_default'].
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the metadata config.
#   Defaults to false.
#
class neutron::agents::ovn_metadata (
  $shared_secret,
  $package_ensure            = 'present',
  Boolean $enabled           = true,
  Boolean $manage_service    = true,
  $debug                     = $facts['os_service_default'],
  $auth_ca_cert              = $facts['os_service_default'],
  $metadata_host             = $facts['os_service_default'],
  $metadata_port             = $facts['os_service_default'],
  $metadata_protocol         = $facts['os_service_default'],
  $metadata_workers          = $facts['os_service_default'],
  $metadata_backlog          = $facts['os_service_default'],
  $metadata_insecure         = $facts['os_service_default'],
  $nova_client_cert          = $facts['os_service_default'],
  $nova_client_priv_key      = $facts['os_service_default'],
  $ovsdb_connection          = 'tcp:127.0.0.1:6640',
  $ovs_manager               = 'ptcp:6640:127.0.0.1',
  $ovn_sb_connection         = $facts['os_service_default'],
  $ovn_sb_private_key        = $facts['os_service_default'],
  $ovn_sb_certificate        = $facts['os_service_default'],
  $ovn_sb_ca_cert            = $facts['os_service_default'],
  $ovsdb_connection_timeout  = $facts['os_service_default'],
  $ovsdb_retry_max_interval  = $facts['os_service_default'],
  $ovsdb_probe_interval      = $facts['os_service_default'],
  $root_helper               = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $root_helper_daemon        = $facts['os_service_default'],
  $state_path                = $facts['os_service_default'],
  Boolean $purge_config      = false,
) {

  include neutron::deps
  include neutron::params

  warning('ovn-metadata-agent is deprecated')

  resources { 'ovn_metadata_agent_config':
    purge => $purge_config,
  }

  ovn_metadata_agent_config {
    'DEFAULT/debug':                          value => $debug;
    'DEFAULT/auth_ca_cert':                   value => $auth_ca_cert;
    'DEFAULT/nova_metadata_host':             value => $metadata_host;
    'DEFAULT/nova_metadata_port':             value => $metadata_port;
    'DEFAULT/nova_metadata_protocol':         value => $metadata_protocol;
    'DEFAULT/metadata_proxy_shared_secret':   value => $shared_secret, secret => true;
    'DEFAULT/metadata_workers':               value => $metadata_workers;
    'DEFAULT/metadata_backlog':               value => $metadata_backlog;
    'DEFAULT/nova_metadata_insecure':         value => $metadata_insecure;
    'DEFAULT/nova_client_cert':               value => $nova_client_cert;
    'DEFAULT/nova_client_priv_key':           value => $nova_client_priv_key;
    'DEFAULT/state_path':                     value => $state_path;
    'agent/root_helper':                      value => $root_helper;
    'agent/root_helper_daemon':               value => $root_helper_daemon;
    'ovs/ovsdb_connection':                   value => $ovsdb_connection;
    'ovs/ovsdb_connection_timeout':           value => $ovsdb_connection_timeout;
    'ovn/ovsdb_retry_max_interval':           value => $ovsdb_retry_max_interval;
    'ovn/ovsdb_probe_interval':               value => $ovsdb_probe_interval;
    'ovn/ovn_sb_connection':                  value => join(any2array($ovn_sb_connection), ',');
    'ovn/ovn_sb_private_key':                 value => $ovn_sb_private_key;
    'ovn/ovn_sb_certificate':                 value => $ovn_sb_certificate;
    'ovn/ovn_sb_ca_cert':                     value => $ovn_sb_ca_cert;
  }

  if $neutron::params::ovn_metadata_agent_package {
    package { 'ovn-metadata':
      ensure => $package_ensure,
      name   => $neutron::params::ovn_metadata_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'ovn-metadata':
      ensure => $service_ensure,
      name   => $neutron::params::ovn_metadata_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
    Ovn_metadata_agent_config<||> ~> Service['ovn-metadata']
    Exec['Set OVS Manager'] -> Service['ovn-metadata']
  }

  # Set OVS manager so that metadata agent can connect to Open vSwitch
  # NOTE(tkajinam): We use ensure_resource to avoid conflict with
  #                 neutron::agents::ml2::ovn
  ensure_resource('exec', 'Set OVS Manager', {
    'command' => "ovs-vsctl set-manager ${ovs_manager}",
    'unless'  => "ovs-vsctl get-manager | grep \"${ovs_manager}\"",
    'path'    => '/usr/sbin:/usr/bin:/sbin:/bin',
  })

  Package<| title == 'ovn-metadata' |> -> Exec['Set OVS Manager']
}
