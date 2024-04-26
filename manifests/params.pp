# == Class: neutron::params
#
# Parameters for puppet-neutron
#
class neutron::params {
  include openstacklib::defaults

  $client_package              = 'python3-neutronclient'
  $ovs_agent_service           = 'neutron-openvswitch-agent'
  $linuxbridge_agent_service   = 'neutron-linuxbridge-agent'
  $macvtap_agent_service       = 'neutron-macvtap-agent'
  $dhcp_agent_service          = 'neutron-dhcp-agent'
  $metering_agent_service      = 'neutron-metering-agent'
  $l3_agent_service            = 'neutron-l3-agent'
  $metadata_agent_service      = 'neutron-metadata-agent'
  $ovn_metadata_agent_service  = 'neutron-ovn-metadata-agent'
  $ovn_agent_service           = 'neutron-ovn-agent'
  $bgp_dragent_service         = 'neutron-bgp-dragent'
  $bgpvpn_plugin_package       = 'python3-networking-bgpvpn'
  $l2gw_agent_service          = 'neutron-l2gw-agent'
  $sfc_package                 = 'python3-networking-sfc'
  $user                        = 'neutron'
  $group                       = 'neutron'
  $arista_plugin_package       = 'python3-networking-arista'

  case $facts['os']['family'] {
    'RedHat': {
      $package_name                       = 'openstack-neutron'
      $server_service                     = 'neutron-server'
      $server_package                     = undef
      $api_package_name                   = undef
      $api_service_name                   = undef
      $rpc_package_name                   = 'openstack-neutron-rpc-server'
      $rpc_service_name                   = 'neutron-rpc-server.service'
      $ml2_server_package                 = 'openstack-neutron-ml2'
      $ovs_agent_package                  = 'openstack-neutron-openvswitch'
      $ovs_cleanup_service                = 'neutron-ovs-cleanup'
      $destroy_patch_ports_service        = 'neutron-destroy-patch-ports'
      $linuxbridge_agent_package          = 'openstack-neutron-linuxbridge'
      $sriov_nic_agent_service            = 'neutron-sriov-nic-agent'
      $sriov_nic_agent_package            = 'openstack-neutron-sriov-nic-agent'
      $macvtap_agent_package              = 'openstack-neutron-macvtap-agent'
      $dhcp_agent_package                 = undef
      $metering_agent_package             = 'openstack-neutron-metering-agent'
      $vpnaas_agent_package               = 'openstack-neutron-vpnaas'
      $libreswan_package                  = 'libreswan'
      $strongswan_package                 = 'strongswan'
      $taas_package                       = 'python3-tap-as-a-service'
      $l2gw_agent_package                 = 'openstack-neutron-l2gw-agent'
      $l2gw_package                       = 'python3-networking-l2gw'
      $ovn_metadata_agent_package         = 'openstack-neutron-ovn-metadata-agent'
      $ovn_agent_package                  = 'openstack-neutron-ovn-agent'
      $dynamic_routing_package            = 'python3-neutron-dynamic-routing'
      $bgp_dragent_package                = 'openstack-neutron-bgp-dragent'
      $bagpipe_bgp_package                = 'openstack-bagpipe-bgp'
      $bagpipe_bgp_service                = 'bagpipe-bgp'
      $bgpvpn_bagpipe_package             = 'python3-networking-bagpipe'
      $metadata_agent_package             = undef
      $l3_agent_package                   = undef
      $neutron_wsgi_script_path           = '/var/www/cgi-bin/neutron'
      $neutron_wsgi_script_source         = '/usr/bin/neutron-api'
      $networking_baremetal_package       = 'python3-networking-baremetal'
      $networking_baremetal_agent_package = 'python3-ironic-neutron-agent'
      $networking_baremetal_agent_service = 'ironic-neutron-agent'
    }
    'Debian': {
      $package_name                       = 'neutron-common'
      if $facts['os']['name'] == 'Debian' {
        $ml2_server_package               = undef
        $server_service                   = undef
        $server_package                   = undef
        $api_package_name                 = 'neutron-api'
        $api_service_name                 = 'neutron-api'
        $rpc_package_name                 = 'neutron-rpc-server'
        $rpc_service_name                 = 'neutron-rpc-server'
        $bagpipe_bgp_package              = 'networking-bagpipe-bgp-agent'
        $bagpipe_bgp_service              = 'networking-bagpipe-bgp-agent'
      } else {
        $ml2_server_package               = 'neutron-plugin-ml2'
        $server_service                   = 'neutron-server'
        $server_package                   = 'neutron-server'
        $api_package_name                 = undef
        $api_service_name                 = undef
        $rpc_package_name                 = undef
        $rpc_service_name                 = undef
        $bagpipe_bgp_package              = undef
        $bagpipe_bgp_service              = undef
      }
      $dynamic_routing_package            = 'python3-neutron-dynamic-routing'
      $bgp_dragent_package                = 'neutron-bgp-dragent'
      $bgpvpn_bagpipe_package             = 'python3-networking-bagpipe'
      $ovs_agent_package                  = 'neutron-openvswitch-agent'
      $ovs_cleanup_service                = undef
      $destroy_patch_ports_service        = undef
      $linuxbridge_agent_package          = 'neutron-linuxbridge-agent'
      $sriov_nic_agent_service            = 'neutron-sriov-agent'
      $sriov_nic_agent_package            = 'neutron-sriov-agent'
      $macvtap_agent_package              = 'neutron-macvtap-agent'
      $dhcp_agent_package                 = 'neutron-dhcp-agent'
      $metering_agent_package             = 'neutron-metering-agent'
      $vpnaas_agent_package               = 'python3-neutron-vpnaas'
      $libreswan_package                  = 'libreswan'
      $strongswan_package                 = 'strongswan'
      $taas_package                       = 'python3-neutron-taas'
      $metadata_agent_package             = 'neutron-metadata-agent'
      $l3_agent_package                   = 'neutron-l3-agent'
      $l2gw_agent_package                 = 'neutron-l2gateway-agent'
      $l2gw_package                       = 'python3-networking-l2gw'
      $ovn_metadata_agent_package         = 'neutron-ovn-metadata-agent'
      $ovn_agent_package                  = 'neutron-ovn-agent'
      $neutron_wsgi_script_path           = '/usr/lib/cgi-bin/neutron'
      $neutron_wsgi_script_source         = '/usr/bin/neutron-api'
      $networking_baremetal_package       = 'python3-ironic-neutron-agent'
      $networking_baremetal_agent_package = 'ironic-neutron-agent'
      $networking_baremetal_agent_service = 'ironic-neutron-agent'
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
