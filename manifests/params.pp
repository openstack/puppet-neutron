class quantum::params {

  $quantum_conf = '/etc/quantum/quantum.conf'
  $quantum_conf_tag = regsubst($quantum_conf, '/', '_', 'G')
  $quantum_paste_api_ini = '/etc/quantum/api-paste.ini'
  $quantum_paste_api_ini_tag = regsubst($quantum_paste_api_ini, '/', '_', 'G')
  $quantum_dhcp_agent_ini = '/etc/quantum/dhcp_agent.ini'
  $quantum_dhcp_agent_ini_tag = regsubst($quantum_dhcp_agent_ini, '/', '_', 'G')
  $quantum_l3_agent_ini   = '/etc/quantum/l3_agent.ini'
  $quantum_l3_agent_ini_tag = regsubst($quantum_l3_agent_ini, '/', '_', 'G')

  $quantum_ovs_plugin_ini = '/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini'
  $quantum_ovs_plugin_ini_tag = regsubst($quantum_ovs_plugin_ini, '/', '_', 'G') 
  

  case $::osfamily {
    'Debian': {
      $package_name       = 'quantum-server'
      $service_name       = 'quantum-server'
      $ovs_package_agent  = 'quantum-plugin-openvswitch-agent'
      $ovs_package_server = 'quantum-plugin-openvswitch'
      $ovs_service_agent  = 'quantum-agent'
      $ovs_package        = 'openvswitch-switch'
      $ovs_service        = 'openvswitch-switch'
      $dhcp_package       = 'quantum-dhcp-agent'
      $dhcp_service       = 'quantum-dhcp-agent'
      $l3_package         = 'quantum-l3-agent'
      $l3_service         = 'quantum-l3-agent'
      $cliff_name         = 'python-cliff'
      $kernel_headers     = "linux-headers-${::kernelrelease}"
    }
  }
}
