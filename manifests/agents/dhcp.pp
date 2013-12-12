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
# [*debug*]
#   (optional) Show debugging output in log. Defaults to false.
#
# [*state_path*]
#   (optional) Where to store dnsmasq state files. This directory must be
#   writable by the user executing the agent. Defaults to '/var/lib/neutron'.
#
# [*resync_interval*]
#   (optional) The DHCP agent will resync its state with Neutron to recover
#   from any transient notification or rpc errors. The interval is number of
#   seconds between attempts. Defaults to 30.
#
# [*interface_driver*]
#   (optional) Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*dhcp_driver*]
#   (optional) Defaults to 'neutron.agent.linux.dhcp.Dnsmasq'.
#
# [*root_helper*]
#   (optional) Defaults to 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf'.
#   Addresses bug: https://bugs.launchpad.net/neutron/+bug/1182616
#   Note: This can safely be removed once the module only targets the Havana release.
#
# [*use_namespaces*]
#   (optional) Allow overlapping IP (Must have kernel build with
#   CONFIG_NET_NS=y and iproute2 package that supports namespaces).
#   Defaults to true.
#
class neutron::agents::dhcp (
  $package_ensure   = present,
  $enabled          = true,
  $debug            = false,
  $state_path       = '/var/lib/neutron',
  $resync_interval  = 30,
  $interface_driver = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $dhcp_driver      = 'neutron.agent.linux.dhcp.Dnsmasq',
  $root_helper      = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $use_namespaces   = true
) {

  include neutron::params

  Neutron_config<||>            ~> Service['neutron-dhcp-service']
  Neutron_dhcp_agent_config<||> ~> Service['neutron-dhcp-service']

  case $dhcp_driver {
    /\.Dnsmasq/: {
      Package[$::neutron::params::dnsmasq_packages] -> Package<| title == 'neutron-dhcp-agent' |>
      ensure_packages($::neutron::params::dnsmasq_packages)
    }
    default: {
      fail("Unsupported dhcp_driver ${dhcp_driver}")
    }
  }

  # The DHCP agent loads both neutron.ini and its own file.
  # This only lists config specific to the agent.  neutron.ini supplies
  # the rest.
  neutron_dhcp_agent_config {
    'DEFAULT/debug':              value => $debug;
    'DEFAULT/state_path':         value => $state_path;
    'DEFAULT/resync_interval':    value => $resync_interval;
    'DEFAULT/interface_driver':   value => $interface_driver;
    'DEFAULT/dhcp_driver':        value => $dhcp_driver;
    'DEFAULT/use_namespaces':     value => $use_namespaces;
    'DEFAULT/root_helper':        value => $root_helper;
  }

  if $::neutron::params::dhcp_agent_package {
    Package['neutron']            -> Package['neutron-dhcp-agent']
    Package['neutron-dhcp-agent'] -> Neutron_config<||>
    Package['neutron-dhcp-agent'] -> Neutron_dhcp_agent_config<||>
    package { 'neutron-dhcp-agent':
      ensure  => $package_ensure,
      name    => $::neutron::params::dhcp_agent_package,
    }
  } else {
    # Some platforms (RedHat) do not provide a neutron DHCP agent package.
    # The neutron DHCP agent config file is provided by the neutron package.
    Package['neutron'] -> Neutron_dhcp_agent_config<||>
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'neutron-dhcp-service':
    ensure  => $ensure,
    name    => $::neutron::params::dhcp_agent_service,
    enable  => $enabled,
    require => Class['neutron'],
  }
}
