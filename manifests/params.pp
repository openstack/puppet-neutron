class quantum::params {
  case $::osfamily {
    'Debian', 'Ubuntu': {
      $package_name       = 'quantum-common'
      $server_package     = 'quantum-server'
      $server_service     = 'quantum-server'

      $ovs_agent_package  = 'quantum-plugin-openvswitch-agent'
      $ovs_agent_service  = 'quantum-plugin-openvswitch-agent'
      $ovs_server_package = 'quantum-plugin-openvswitch'

      $dhcp_agent_package = 'quantum-dhcp-agent'
      $dhcp_agent_service = 'quantum-dhcp-agent'

      $dnsmasq_packages   = ['dnsmasq-base', 'dnsmasq-utils']

      $isc_dhcp_packages  = ['isc-dhcp-server']

      $l3_agent_package   = 'quantum-l3-agent'
      $l3_agent_service   = 'quantum-l3-agent'

      $cliff_package      = 'python-cliff'
      $kernel_headers     = "linux-headers-${::kernelrelease}"
    }
  }
}
