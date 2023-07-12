# == Class: neutron::agents::ml2::ovn
#
# Setup and configure neutron OVN Neutron Agent.
#
# === Parameters
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
#   Debug. Defaults to $facts['os_service_default'].
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
# [*ovn_nb_connection*]
#   (optional) The connection string for the OVN_Northbound OVSDB.
#   Defaults to 'tcp:127.0.0.1:6641'
#
# [*ovn_sb_connection*]
#   (optional) The connection string for the OVN_Southbound OVSDB
#   Defaults to '$facts['os_service_default']'
#
# [*ovn_nb_private_key*]
#   (optional) The PEM file with private key for SSL connection to OVN-NB-DB
#   Defaults to $facts['os_service_default']
#
# [*ovn_nb_certificate*]
#   (optional) The PEM file with certificate that certifies the private
#   key specified in ovn_nb_private_key
#   Defaults to $facts['os_service_default']
#
# [*ovn_nb_ca_cert*]
#   (optional) The PEM file with CA certificate that OVN should use to
#   verify certificates presented to it by SSL peers
#   Defaults to $facts['os_service_default']
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
#   (optional) Timeout in seconds for the OVSDB connection transaction.
#   Defaults to $facts['os_service_default']
#
# [*ovndb_connection_timeout*]
#   (optional) Timeout in seconds for the OVNDB connection transaction. This
#   is used for OVN DB connection.
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
#   (optional) Use "sudo neutron-rootwrap /etc/neutron/rootwrap.conf" to use the real
#   root filter facility. Change to "sudo" to skip the filtering and just run the command
#   directly
#   Defaults to 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf'.
#
# [*root_helper_daemon*]
#   (optional) Root helper daemon application to use when possible.
#   Defaults to $facts['os_service_default'].
#
# [*state_path*]
#   (optional) Where to store state files. This directory must be writable
#   by the user executing the agent
#   Defaults to '/var/lib/neutron'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the metadata config.
#   Defaults to false.
#
class neutron::agents::ml2::ovn (
  $package_ensure           = 'present',
  Boolean $enabled          = true,
  Boolean $manage_service   = true,
  $debug                    = $facts['os_service_default'],
  $ovsdb_connection         = 'tcp:127.0.0.1:6640',
  $ovs_manager              = 'ptcp:6640:127.0.0.1',
  $ovn_nb_connection        = $facts['os_service_default'],
  $ovn_sb_connection        = $facts['os_service_default'],
  $ovn_nb_private_key       = $facts['os_service_default'],
  $ovn_nb_certificate       = $facts['os_service_default'],
  $ovn_nb_ca_cert           = $facts['os_service_default'],
  $ovn_sb_private_key       = $facts['os_service_default'],
  $ovn_sb_certificate       = $facts['os_service_default'],
  $ovn_sb_ca_cert           = $facts['os_service_default'],
  $ovsdb_connection_timeout = $facts['os_service_default'],
  $ovndb_connection_timeout = $facts['os_service_default'],
  $ovsdb_retry_max_interval = $facts['os_service_default'],
  $ovsdb_probe_interval     = $facts['os_service_default'],
  $root_helper              = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $root_helper_daemon       = $facts['os_service_default'],
  $state_path               = '/var/lib/neutron',
  $purge_config             = false,
) {

  include neutron::deps
  include neutron::params

  resources { 'neutron_agent_ovn':
    purge => $purge_config,
  }

  neutron_agent_ovn {
    'DEFAULT/debug':                value => $debug;
    'DEFAULT/state_path':           value => $state_path;
    'agent/root_helper':            value => $root_helper;
    'agent/root_helper_daemon':     value => $root_helper_daemon;
    'ovs/ovsdb_connection':         value => $ovsdb_connection;
    'ovs/ovsdb_connection_timeout': value => $ovsdb_connection_timeout;
    'ovn/ovsdb_connection_timeout': value => $ovndb_connection_timeout;
    'ovn/ovsdb_retry_max_interval': value => $ovsdb_retry_max_interval;
    'ovn/ovsdb_probe_interval':     value => $ovsdb_probe_interval;
    'ovn/ovn_sb_connection':        value => join(any2array($ovn_sb_connection), ',');
    'ovn/ovn_nb_connection':        value => join(any2array($ovn_nb_connection), ',');
    'ovn/ovn_nb_private_key':       value => $ovn_nb_private_key;
    'ovn/ovn_nb_certificate':       value => $ovn_nb_certificate;
    'ovn/ovn_nb_ca_cert':           value => $ovn_nb_ca_cert;
    'ovn/ovn_sb_private_key':       value => $ovn_sb_private_key;
    'ovn/ovn_sb_certificate':       value => $ovn_sb_certificate;
    'ovn/ovn_sb_ca_cert':           value => $ovn_sb_ca_cert;
  }

  package { 'neutron-ovn-agent':
    ensure => $package_ensure,
    name   => $::neutron::params::ovn_agent_package,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-ovn-agent':
      ensure => $service_ensure,
      name   => $::neutron::params::ovn_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
    Exec['Set OVS Manager'] -> Service['neutron-ovn-agent']
  }

  # Set OVS manager so that the OVN Neutron Agent can connect to Open vSwitch
  # NOTE(tkajinam): We use ensure_resource to avoid conflict with
  #                 neutron::agents::ovn_metadata
  ensure_resource('exec', 'Set OVS Manager', {
    'command' => "ovs-vsctl set-manager ${ovs_manager}",
    'unless'  => "ovs-vsctl get-manager | grep \"${ovs_manager}\"",
    'path'    => '/usr/sbin:/usr/bin:/sbin:/bin',
  })

  Package<| title == 'neutron-ovn-agent' |> -> Exec['Set OVS Manager']
}
