# == Class: neutron
#
# Installs the neutron package and configures
# /etc/neutron/neutron.conf
#
# === Parameters:
#
# [*enabled*]
#   (required) Whether or not to enable the neutron service
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
#   (optional) Neutron plugin provider
#   Defaults to neutron.plugins.openvswitch.ovs_neutron_plugin.OVSNeutronPluginV2 (Open-vSwitch)
#   Could be:
#   neutron.plugins.bigswitch.plugin.NeutronRestProxyV2
#   neutron.plugins.brocade.NeutronPlugin.BrocadePluginV2
#   neutron.plugins.cisco.network_plugin.PluginV2
#   neutron.plugins.linuxbridge.lb_neutron_plugin.LinuxBridgePluginV2
#   neutron.plugins.midonet.plugin.MidonetPluginV2
#   neutron.plugins.ml2.plugin.Ml2Plugin
#   neutron.plugins.nec.nec_plugin.NECPluginV2
#   neutron.plugins.nicira.NeutronPlugin.NvpPluginV2
#   neutron.plugins.plumgrid.plumgrid_plugin.plumgrid_plugin.NeutronPluginPLUMgridV2
#   neutron.plugins.ryu.ryu_neutron_plugin.RyuNeutronPluginV2
#
# [*service_plugins*]
#   (optional) Advanced service modules.
#   Could be an array that can have these elements:
#   neutron.services.firewall.fwaas_plugin.FirewallPlugin
#   neutron.services.loadbalancer.plugin.LoadBalancerPlugin
#   neutron.services.vpn.plugin.VPNDriverPlugin
#   neutron.services.metering.metering_plugin.MeteringPlugin
#   Defaults to empty
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
# [*dhcp_agents_per_network*]
#   (optional) Number of DHCP agents scheduled to host a network.
#   This enables redundant DHCP agents for configured networks.
#   Defaults to 1
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
#   Defaults to neutron

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
#   (optional) array of rabbitmq servers for HA.
#   A single IP address, such as a VIP, can be used for load-balancing
#   multiple RabbitMQ Brokers.
#   Defaults to false
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
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to false
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to LOG_USER
#
class neutron (
  $enabled                     = true,
  $package_ensure              = 'present',
  $verbose                     = false,
  $debug                       = false,
  $bind_host                   = '0.0.0.0',
  $bind_port                   = '9696',
  $core_plugin                 = 'neutron.plugins.openvswitch.ovs_neutron_plugin.OVSNeutronPluginV2',
  $service_plugins             = undef,
  $auth_strategy               = 'keystone',
  $base_mac                    = 'fa:16:3e:00:00:00',
  $mac_generation_retries      = 16,
  $dhcp_lease_duration         = 120,
  $dhcp_agents_per_network     = 1,
  $allow_bulk                  = true,
  $allow_overlapping_ips       = false,
  $root_helper                 = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $control_exchange            = 'neutron',
  $rpc_backend                 = 'neutron.openstack.common.rpc.impl_kombu',
  $rabbit_password             = false,
  $rabbit_host                 = 'localhost',
  $rabbit_hosts                = false,
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
  $qpid_reconnect_interval     = 0,
  $use_syslog                  = false,
  $log_facility                = 'LOG_USER',
) {

  include neutron::params

  Package['neutron'] -> Neutron_config<||>

  File {
    require => Package['neutron'],
    owner   => 'root',
    group   => 'neutron',
    mode    => '0640',
  }

  file { '/etc/neutron':
    ensure  => directory,
    mode    => '0750',
  }

  file { '/etc/neutron/neutron.conf': }

  package { 'neutron':
    ensure => $package_ensure,
    name   => $::neutron::params::package_name,
  }

  neutron_config {
    'DEFAULT/verbose':                 value => $verbose;
    'DEFAULT/debug':                   value => $debug;
    'DEFAULT/bind_host':               value => $bind_host;
    'DEFAULT/bind_port':               value => $bind_port;
    'DEFAULT/auth_strategy':           value => $auth_strategy;
    'DEFAULT/core_plugin':             value => $core_plugin;
    'DEFAULT/base_mac':                value => $base_mac;
    'DEFAULT/mac_generation_retries':  value => $mac_generation_retries;
    'DEFAULT/dhcp_lease_duration':     value => $dhcp_lease_duration;
    'DEFAULT/dhcp_agents_per_network': value => $dhcp_agents_per_network;
    'DEFAULT/allow_bulk':              value => $allow_bulk;
    'DEFAULT/allow_overlapping_ips':   value => $allow_overlapping_ips;
    'DEFAULT/control_exchange':        value => $control_exchange;
    'DEFAULT/rpc_backend':             value => $rpc_backend;
    'AGENT/root_helper':               value => $root_helper;
  }

  if $service_plugins {
    if is_array($service_plugins) {
      neutron_config { 'DEFAULT/service_plugins': value => join($service_plugins, ',') }
    } else {
      fail('service_plugins should be an array.')
    }
  }

  if $rpc_backend == 'neutron.openstack.common.rpc.impl_kombu' {
    if ! $rabbit_password {
      fail('When rpc_backend is rabbitmq, you must set rabbit password')
    }
    if $rabbit_hosts {
      neutron_config { 'DEFAULT/rabbit_hosts':     value  => join($rabbit_hosts, ',') }
      neutron_config { 'DEFAULT/rabbit_ha_queues': value  => true }
    } else  {
      neutron_config { 'DEFAULT/rabbit_host':      value => $rabbit_host }
      neutron_config { 'DEFAULT/rabbit_port':      value => $rabbit_port }
      neutron_config { 'DEFAULT/rabbit_hosts':     value => "${rabbit_host}:${rabbit_port}" }
      neutron_config { 'DEFAULT/rabbit_ha_queues': value => false }
    }

    neutron_config {
      'DEFAULT/rabbit_userid':       value => $rabbit_user;
      'DEFAULT/rabbit_password':     value => $rabbit_password;
      'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
    }
  }

  if $rpc_backend == 'neutron.openstack.common.rpc.impl_qpid' {
    neutron_config {
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

  if $use_syslog {
    neutron_config {
      'DEFAULT/use_syslog':           value => true;
      'DEFAULT/syslog_log_facility':  value => $log_facility;
    }
  } else {
    neutron_config {
      'DEFAULT/use_syslog':           value => false;
    }
  }
}
