# == Class: quantum
#
# Installs the quantum package and configures
# /etc/quantum/quantum.conf
#
# === Parameters:
#
# [*enabled*]
#   (required) Whether or not to enable the quantum service
#   true/false
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to 'present'
#
# [*verbose*]
#   (optional) Verbose logging
#   Defaults to False
#
# [*debug*]
#   (optional) Print debug messages in the logs
#   Defaults to False
#
# [*bind_host*]
#   (optional) The IP/interface to bind to
#   Defaults to 0.0.0.0 (all interfaces)
#
# [*bind_port*]
#   (optional) The port to use
#   Defaults to 9696
#
# [*core_plugin*]
#   (optional) Quantum plugin provider
#   Defaults to OVSQquantumPluginV2 (openvswitch)
#
# [*auth_strategy*]
#   (optional) How to authenticate
#   Defaults to 'keystone'. 'noauth' is the only other valid option
#
# [*base_mac*]
#   (optional) The MAC address pattern to use.
#   Defaults to fa:16:3e:00:00:00
#
# [*mac_generation_retries*]
#   (optional) How many times to try to generate a unique mac
#   Defaults to 16
#
# [*dhcp_lease_duration*]
#   (optional) DHCP lease
#   Defaults to 120 seconds
#
# [*allow_bulk*]
#   (optional) Enable bulk crud operations
#   Defaults to true
#
# [*allow_overlapping_ips*]
#   (optional) Enables network namespaces
#   Defaults to false
#
# [*control_exchange*]
#   (optional) What RPC queue/exchange to use
#   Defaults to quantum

# [*rpc_backend*]
#   (optional) what rpc/queuing service to use
#   Defaults to impl_kombu (rabbitmq)
#
# [*rabbit_password*]
# [*rabbit_host*]
# [*rabbit_port*]
# [*rabbit_user*]
#   (optional) Various rabbitmq settings
#
# [*rabbit_hosts*]
#   (optional) array of rabbitmq servers for HA
#   Defaults to empty
#
# [*qpid_hostname*]
# [*qpid_port*]
# [*qpid_username*]
# [*qpid_password*]
# [*qpid_heartbeat*]
# [*qpid_protocol*]
# [*qpid_tcp_nodelay*]
# [*qpid_reconnect*]
# [*qpid_reconnect_timeout*]
# [*qpid_reconnect_limit*]
# [*qpid_reconnect_interval*]
# [*qpid_reconnect_interval_min*]
# [*qpid_reconnect_interval_max*]
#   (optional) various QPID options
#
class quantum (
  $enabled                     = true,
  $package_ensure              = 'present',
  $verbose                     = false,
  $debug                       = false,
  $bind_host                   = '0.0.0.0',
  $bind_port                   = '9696',
  $core_plugin                 = 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
  $auth_strategy               = 'keystone',
  $base_mac                    = 'fa:16:3e:00:00:00',
  $mac_generation_retries      = 16,
  $dhcp_lease_duration         = 120,
  $allow_bulk                  = true,
  $allow_overlapping_ips       = false,
  $root_helper                 = 'sudo quantum-rootwrap /etc/quantum/rootwrap.conf',
  $control_exchange            = 'quantum',
  $rpc_backend                 = 'quantum.openstack.common.rpc.impl_kombu',
  $rabbit_password             = false,
  $rabbit_host                 = 'localhost',
  $rabbit_hosts                = undef,
  $rabbit_port                 = '5672',
  $rabbit_user                 = 'guest',
  $rabbit_virtual_host         = '/',
  $qpid_hostname               = 'localhost',
  $qpid_port                   = '5672',
  $qpid_username               = 'guest',
  $qpid_password               = 'guest',
  $qpid_heartbeat              = 60,
  $qpid_protocol               = 'tcp',
  $qpid_tcp_nodelay            = true,
  $qpid_reconnect              = true,
  $qpid_reconnect_timeout      = 0,
  $qpid_reconnect_limit        = 0,
  $qpid_reconnect_interval_min = 0,
  $qpid_reconnect_interval_max = 0,
  $qpid_reconnect_interval     = 0
) {

  include quantum::params

  Package['quantum'] -> Quantum_config<||>

  File {
    require => Package['quantum'],
    owner   => 'root',
    group   => 'quantum',
    mode    => '0640',
  }

  file { '/etc/quantum':
    ensure  => directory,
    mode    => '0750',
  }

  file { '/etc/quantum/quantum.conf': }

  package { 'quantum':
    name   => $::quantum::params::package_name,
    ensure => $package_ensure
  }

  quantum_config {
    'DEFAULT/verbose':                value => $verbose;
    'DEFAULT/debug':                  value => $debug;
    'DEFAULT/bind_host':              value => $bind_host;
    'DEFAULT/bind_port':              value => $bind_port;
    'DEFAULT/auth_strategy':          value => $auth_strategy;
    'DEFAULT/core_plugin':            value => $core_plugin;
    'DEFAULT/base_mac':               value => $base_mac;
    'DEFAULT/mac_generation_retries': value => $mac_generation_retries;
    'DEFAULT/dhcp_lease_duration':    value => $dhcp_lease_duration;
    'DEFAULT/allow_bulk':             value => $allow_bulk;
    'DEFAULT/allow_overlapping_ips':  value => $allow_overlapping_ips;
    'DEFAULT/root_helper':            value => $root_helper;
    'DEFAULT/control_exchange':       value => $control_exchange;
    'DEFAULT/rpc_backend':            value => $rpc_backend;
  }

  if $rpc_backend == 'quantum.openstack.common.rpc.impl_kombu' {
    if ! $rabbit_password {
      fail("When rpc_backend is rabbitmq, you must set rabbit password")
    }
    if $rabbit_hosts {
      quantum_config { 'DEFAULT/rabbit_host':  ensure => absent }
      quantum_config { 'DEFAULT/rabbit_port':  ensure => absent }
      quantum_config { 'DEFAULT/rabbit_hosts': value => join($rabbit_hosts, ',') }
    } else {
      quantum_config { 'DEFAULT/rabbit_host':  value => $rabbit_host }
      quantum_config { 'DEFAULT/rabbit_port':  value => $rabbit_port }
      quantum_config { 'DEFAULT/rabbit_hosts': value => "${rabbit_host}:${rabbit_port}" }
    }

    if size($rabbit_hosts) > 1 {
      quantum_config { 'DEFAULT/rabbit_ha_queues': value => true }
    } else {
      quantum_config { 'DEFAULT/rabbit_ha_queues': value => false }
    }
    quantum_config {
      'DEFAULT/rabbit_userid':       value => $rabbit_user;
      'DEFAULT/rabbit_password':     value => $rabbit_password;
      'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
    }
  }

  if $rpc_backend == 'quantum.openstack.common.rpc.impl_qpid' {
    quantum_config {
      'DEFAULT/qpid_hostname':               value => $qpid_hostname;
      'DEFAULT/qpid_port':                   value => $qpid_port;
      'DEFAULT/qpid_username':               value => $qpid_username;
      'DEFAULT/qpid_password':               value => $qpid_password;
      'DEFAULT/qpid_heartbeat':              value => $qpid_heartbeat;
      'DEFAULT/qpid_protocol':               value => $qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay':            value => $qpid_tcp_nodelay;
      'DEFAULT/qpid_reconnect':              value => $qpid_reconnect;
      'DEFAULT/qpid_reconnect_timeout':      value => $qpid_reconnect_timeout;
      'DEFAULT/qpid_reconnect_limit':        value => $qpid_reconnect_limit;
      'DEFAULT/qpid_reconnect_interval_min': value => $qpid_reconnect_interval_min;
      'DEFAULT/qpid_reconnect_interval_max': value => $qpid_reconnect_interval_max;
      'DEFAULT/qpid_reconnect_interval':     value => $qpid_reconnect_interval;
    }
  }

  # Any machine using Quantum / OVS endpoints with certain nova networking configs will
  # have protetion issues writing unexpected files unless qemu is changed appropriately.
  # See: https://bugs.launchpad.net/openstack-cisco/+bug/1086255
  # TODO: this feels dirty. Maybe it should be moved elsewhere?
  @file { '/etc/libvirt/qemu.conf':
    ensure => present,
    notify => Exec[ '/etc/init.d/libvirt-bin restart'],
    source => 'puppet:///modules/quantum/qemu.conf',
  }

  @exec { '/etc/init.d/libvirt-bin restart':
    refreshonly => true,
  }

}
