# == Class: neutron::agents::dhcp
#
# Setups Neutron DHCP agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enabled*]
#   (optional) Enable state for service. Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   (optional) Show debugging output in log.
#   Defaults to $facts['os_service_default'].
#
# [*state_path*]
#   (optional) Where to store dnsmasq state files. This directory must be
#   writable by the user executing the agent. Defaults to '/var/lib/neutron'.
#
# [*resync_interval*]
#   (optional) The DHCP agent will resync its state with Neutron to recover
#   from any transient notification or rpc errors. The interval is number of
#   seconds between attempts.
#   Defaults to $facts['os_service_default'].
#
# [*interface_driver*]
#   (optional) The driver used to manage the virtual interface.
#   Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*dhcp_driver*]
#   (optional) Defaults to $facts['os_service_default'].
#
# [*root_helper*]
#   (optional) Defaults to 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf'.
#   Addresses bug: https://bugs.launchpad.net/neutron/+bug/1182616
#   Note: This can safely be removed once the module only targets the Havana release.
#
# [*dnsmasq_config_file*]
#   (optional) Override the default dnsmasq settings with this file.
#   Defaults to $facts['os_service_default']
#
# [*dnsmasq_dns_servers*]
#   (optional) List of servers to use as dnsmasq forwarders.
#   Defaults to $facts['os_service_default'].
#
# [*dnsmasq_base_log_dir*]
#   (optional) base log dir for dnsmasq logging.
#   Defaults to $facts['os_service_default'].
#
# [*dnsmasq_local_resolv*]
#   (optional) Enables the dnsmasq service to provide name resolution for instances
#   via DNS resolvers on the host running the DHCP agent.
#   Defaults to $facts['os_service_default'].
#
# [*dnsmasq_lease_max*]
#   (optional) Limit number of leases to prevent a denial-of-service.
#   Defaults to $facts['os_service_default'].
#
# [*dnsmasq_enable_addr6_list*]
#   (optional) Enable dhcp-host entry with list of addresses when port has
#   multiple IPv6 addresses in the same subnet.
#   Defaults to $facts['os_service_default'].
#
# [*enable_isolated_metadata*]
#   (optional) enable metadata support on isolated networks.
#   Defaults to false.
#
# [*enable_force_metadata*]
#   (optional) enable metadata support on all networks.
#   Defaults to false.
#
# [*enable_metadata_network*]
#   (optional) Allows for serving metadata requests coming from a dedicated metadata
#   access network whose cidr is 169.254.169.254/16 (or larger prefix), and is
#   connected to a Neutron router from which the VMs send metadata request.
#   This option requires enable_isolated_metadata = True
#   Defaults to false.
#
# [*dhcp_broadcast_reply*]
#   (optional) Use broadcast in DHCP replies
#   Defaults to $facts['os_service_default'].
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the dhcp config.
#   Defaults to false.
#
# [*availability_zone*]
#   (optional) The availability zone of the agent.
#   Neutron will only schedule dhcp on the agent based on availability zone
#   Defaults to $facts['os_service_default']
#
# [*ovs_integration_bridge*]
#   (optional) Name of Open vSwitch bridge to use
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_connection*]
#   (optional) The URI used to connect to the local OVSDB server
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_agent_ssl_key_file*]
#   (optional) The SSL key file to use for Neutron agents to connect to OVSDB
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_agent_ssl_cert_file*]
#   (optional) The SSL cert file to use for Neutron agents to connect to OVSDB
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_agent_ssl_ca_file*]
#   (optional) The SSL CA cert file to use for Neutron agents to connect to OVSDB
#   Defaults to $facts['os_service_default']
#
# [*report_interval*]
#   (optional) Set the agent report interval. By default the global report
#   interval in neutron.conf ([agent]/report_interval) is used. This parameter
#   can be used to override the reporting interval for the dhcp-agent.
#   Defaults to $facts['os_service_default']
#
# [*rpc_response_max_timeout*]
#   (Optional) Maximum seconds to wait for a response from an RPC call
#   Defaults to $facts['os_service_default']
#
class neutron::agents::dhcp (
  $package_ensure                   = present,
  Boolean $enabled                  = true,
  Boolean $manage_service           = true,
  $debug                            = $facts['os_service_default'],
  $state_path                       = '/var/lib/neutron',
  $resync_interval                  = $facts['os_service_default'],
  $interface_driver                 = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $dhcp_driver                      = $facts['os_service_default'],
  $root_helper                      = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $dnsmasq_config_file              = $facts['os_service_default'],
  $dnsmasq_dns_servers              = $facts['os_service_default'],
  $dnsmasq_base_log_dir             = $facts['os_service_default'],
  $dnsmasq_local_resolv             = $facts['os_service_default'],
  $dnsmasq_lease_max                = $facts['os_service_default'],
  $dnsmasq_enable_addr6_list        = $facts['os_service_default'],
  Boolean $enable_isolated_metadata = false,
  Boolean $enable_force_metadata    = false,
  Boolean $enable_metadata_network  = false,
  $dhcp_broadcast_reply             = $facts['os_service_default'],
  Boolean $purge_config             = false,
  $availability_zone                = $facts['os_service_default'],
  $ovs_integration_bridge           = $facts['os_service_default'],
  $ovsdb_connection                 = $facts['os_service_default'],
  $ovsdb_agent_ssl_key_file         = $facts['os_service_default'],
  $ovsdb_agent_ssl_cert_file        = $facts['os_service_default'],
  $ovsdb_agent_ssl_ca_file          = $facts['os_service_default'],
  $report_interval                  = $facts['os_service_default'],
  $rpc_response_max_timeout         = $facts['os_service_default'],
) {

  include neutron::deps
  include neutron::params

  if (! ($enable_isolated_metadata or $enable_force_metadata)) and $enable_metadata_network {
    fail('enable_metadata_network to true requires enable_isolated_metadata or enable_force_metadata also enabled.')
  }

  neutron_dhcp_agent_config {
    'DEFAULT/enable_isolated_metadata': value => $enable_isolated_metadata;
    'DEFAULT/force_metadata':           value => $enable_force_metadata;
    'DEFAULT/enable_metadata_network':  value => $enable_metadata_network;
  }

  resources { 'neutron_dhcp_agent_config':
    purge => $purge_config,
  }

  # The DHCP agent loads both neutron.conf and its own file.
  # This only lists config specific to the agent.  neutron.conf supplies
  # the rest.
  neutron_dhcp_agent_config {
    'DEFAULT/debug':                     value => $debug;
    'DEFAULT/state_path':                value => $state_path;
    'DEFAULT/resync_interval':           value => $resync_interval;
    'DEFAULT/interface_driver':          value => $interface_driver;
    'DEFAULT/dhcp_driver':               value => $dhcp_driver;
    'DEFAULT/root_helper':               value => $root_helper;
    'DEFAULT/dhcp_broadcast_reply':      value => $dhcp_broadcast_reply;
    'DEFAULT/dnsmasq_config_file':       value => $dnsmasq_config_file;
    'DEFAULT/dnsmasq_dns_servers':       value => join(any2array($dnsmasq_dns_servers), ',');
    'DEFAULT/dnsmasq_base_log_dir':      value => $dnsmasq_base_log_dir;
    'DEFAULT/dnsmasq_local_resolv':      value => $dnsmasq_local_resolv;
    'DEFAULT/dnsmasq_lease_max':         value => $dnsmasq_lease_max;
    'DEFAULT/dnsmasq_enable_addr6_list': value => $dnsmasq_enable_addr6_list;
    'agent/availability_zone':           value => $availability_zone;
    'agent/report_interval':             value => $report_interval;
    'DEFAULT/rpc_response_max_timeout':  value => $rpc_response_max_timeout;
  }

  if $ovsdb_connection =~ /^ssl:/ {
    $req_ssl_opts = {
      'ovsdb_agent_ssl_key_file'  => $ovsdb_agent_ssl_key_file,
      'ovsdb_agent_ssl_cert_file' => $ovsdb_agent_ssl_cert_file,
      'ovsdb_agent_ssl_ca_file'   => $ovsdb_agent_ssl_ca_file
    }
    $req_ssl_opts.each |$opts| {
      if !$opts[1] or is_service_default($opts[1]) {
        fail(
          "${opts[0]} must be provided when using an SSL ovsdb_connection URI"
        )
      }
    }
  }

  neutron_dhcp_agent_config {
    'ovs/ovsdb_connection':   value => $ovsdb_connection;
    'ovs/integration_bridge': value => $ovs_integration_bridge;
    'ovs/ssl_key_file':       value => $ovsdb_agent_ssl_key_file;
    'ovs/ssl_cert_file':      value => $ovsdb_agent_ssl_cert_file;
    'ovs/ssl_ca_cert_file':   value => $ovsdb_agent_ssl_ca_file;
  }

  if $::neutron::params::dhcp_agent_package {
    package { 'neutron-dhcp-agent':
      ensure => $package_ensure,
      name   => $::neutron::params::dhcp_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-dhcp-service':
      ensure => $service_ensure,
      name   => $::neutron::params::dhcp_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }
}
