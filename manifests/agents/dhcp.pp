class quantum::agents::dhcp (
  $package_ensure   = 'present',
  $enabled          = true,
  $debug            = 'False',
  $state_path       = '/var/lib/quantum',
  $resync_interval  = 30,
  $interface_driver = 'quantum.agent.linux.interface.OVSInterfaceDriver',
  $dhcp_driver      = 'quantum.agent.linux.dhcp.Dnsmasq',
  $use_namespaces   = 'True',
  $root_helper      = 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf'
) {

  include 'quantum::params'

  case $dhcp_driver {
    /\.Dnsmasq/: {
      package { $::quantum::params::dnsmasq_packages:
        ensure => present,
        before => Package['quantum-dhcp-agent'],
      }
      $dhcp_server_packages = $::quantum::params::dnsmasq_packages
    }
    default: {
      fail("${dhcp_driver} is not supported as of now")
    }
  }

  Package['quantum'] -> Package['quantum-dhcp-agent']
  Package['quantum-dhcp-agent'] -> Quantum_dhcp_agent_config<||>
  Package['quantum-dhcp-agent'] -> Quantum_config<||>
  Quantum_config<||> ~> Service['quantum-dhcp-service']
  Quantum_dhcp_agent_config<||> ~> Service['quantum-dhcp-service']

  # The DHCP agent loads both quantum.ini and its own file.
  # This only lists config specific to the agent.  quantum.ini supplies
  # the rest.
  quantum_dhcp_agent_config {
    'DEFAULT/debug':              value => $debug;
    'DEFAULT/state_path':         value => $state_path;
    'DEFAULT/resync_interval':    value => $resync_interval;
    'DEFAULT/interface_driver':   value => $interface_driver;
    'DEFAULT/dhcp_driver':        value => $dhcp_driver;
    'DEFAULT/use_namespaces':     value => $use_namespaces;
    'DEFAULT/root_helper':        value => $root_helper;
  }


  package { 'quantum-dhcp-agent':
    name    => $::quantum::params::dhcp_agent_package,
    ensure  => $package_ensure,
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-dhcp-service':
    name    => $::quantum::params::dhcp_agent_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => [Package['quantum-dhcp-agent'], Class['quantum']],
  }
}
