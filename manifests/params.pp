class quantum::params {

  if($::osfamily == 'Redhat') {
    $package_name       = 'openstack-quantum'
    $server_package     = false
    $server_service     = 'quantum-server'

    $ovs_agent_package  = false
    $ovs_agent_service  = 'quantum-openvswitch-agent'
    $ovs_server_package = 'openstack-quantum-openvswitch'

    $linuxbridge_agent_package  = 'openstack-quantum-linuxbridge'
    $linuxbridge_agent_service  = 'quantum-linuxbridge-agent'
    $linuxbridge_server_package = 'openstack-quantum-linuxbridge'
    $linuxbridge_config_file    = '/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini'

    $dhcp_agent_package = false
    $dhcp_agent_service = 'quantum-dhcp-agent'

    $dnsmasq_packages   = ['dnsmasq', 'dnsmasq-utils']

    $l3_agent_package   = false
    $l3_agent_service   = 'quantum-l3-agent'

    $metadata_agent_service = 'quantum-metadata-agent'

    $cliff_package      = 'python-cliff'

    $kernel_headers     = "linux-headers-${::kernelrelease}"

  } elsif($::osfamily == 'Debian') {

    $package_name       = 'quantum-common'
    $server_package     = 'quantum-server'
    $server_service     = 'quantum-server'

    $ovs_agent_package  = 'quantum-plugin-openvswitch-agent'
    $ovs_agent_service  = 'quantum-plugin-openvswitch-agent'
    $ovs_server_package = 'quantum-plugin-openvswitch'

    $linuxbridge_agent_package  = 'quantum-plugin-linuxbridge-agent'
    $linuxbridge_agent_service  = 'quantum-plugin-linuxbridge-agent'
    $linuxbridge_server_package = 'quantum-plugin-linuxbridge'
    $linuxbridge_config_file    = '/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini'

    $dhcp_agent_package = 'quantum-dhcp-agent'
    $dhcp_agent_service = 'quantum-dhcp-agent'

    $metadata_agent_package = 'quantum-metadata-agent'
    $metadata_agent_service = 'quantum-metadata-agent'

    $dnsmasq_packages   = ['dnsmasq-base', 'dnsmasq-utils']

    $isc_dhcp_packages  = ['isc-dhcp-server']

    $l3_agent_package   = 'quantum-l3-agent'
    $l3_agent_service   = 'quantum-l3-agent'

    $cliff_package      = 'python-cliff'
    $kernel_headers     = "linux-headers-${::kernelrelease}"

  } else {

    fail("Unsupported osfamily ${$::osfamily}")

  }
}
