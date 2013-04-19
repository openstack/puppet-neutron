class quantum (

  $enabled                     = true,
  $package_ensure              = 'present',
  $verbose                     = 'False',
  $debug                       = 'False',
  $bind_host                   = '0.0.0.0',
  $bind_port                   = '9696',
  $core_plugin                 = 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
  $auth_strategy               = 'keystone',
  $base_mac                    = 'fa:16:3e:00:00:00',
  $mac_generation_retries      = 16,
  $dhcp_lease_duration         = 120,
  $allow_bulk                  = 'True',
  $allow_overlapping_ips       = 'False',
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
  include 'quantum::params'

  Package['quantum'] -> Quantum_config<||>

  File {
    require => Package['quantum'],
    owner   => 'root',
    group   => 'quantum',
    mode    => '0750',
  }

  file { '/etc/quantum':
    ensure  => directory,
    owner   => 'root',
    group   => 'quantum',
    mode    => '0750',
    require => Package['quantum']
  }

  file { '/etc/quantum/quantum.conf':
    owner => 'root',
    mode  => '0640',
  }

  file { '/etc/quantum/rootwrap.conf':
    ensure  => present,
    source  => "puppet:///modules/${module_name}/rootwrap.conf",
    require => File['/etc/quantum'],
  }

  package {'quantum':
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
    'DEFAULT/control_exchange':       value => $control_exchange;
    'DEFAULT/rootwrap_conf':          value => '/etc/quantum/rootwrap.conf';
  }

  if $rpc_backend == 'quantum.openstack.common.rpc.impl_kombu' {
    if ! $rabbit_password {
      fail("When rpc_backend is rabbitmq, you must set rabbit password")
    }
    if $rabbit_hosts {
      quantum_config { 'DEFAULT/rabbit_host': ensure => absent }
      quantum_config { 'DEFAULT/rabbit_port': ensure => absent }
      quantum_config { 'DEFAULT/rabbit_hosts': value => join($rabbit_hosts, ',') }
    } else {
      quantum_config { 'DEFAULT/rabbit_host': value => $rabbit_host }
      quantum_config { 'DEFAULT/rabbit_port': value => $rabbit_port }
      quantum_config { 'DEFAULT/rabbit_hosts': value => "${rabbit_host}:${rabbit_port}" }
    }

    if size($rabbit_hosts) > 1 {
      quantum_config { 'DEFAULT/rabbit_ha_queues': value => 'true' }
    } else {
      quantum_config { 'DEFAULT/rabbit_ha_queues': value => 'false' }
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
  # TODO: this feels dirty. Maybe it should be moved elsewhere?
  @file { "/etc/libvirt/qemu.conf":
    ensure => present,
    notify => Exec[ '/etc/init.d/libvirt-bin restart'],
    source => 'puppet:///modules/quantum/qemu.conf',
  }

  exec { '/etc/init.d/libvirt-bin restart':
    refreshonly => true,
  }
}
