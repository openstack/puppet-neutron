# == Class: neutron::params
#
# Parameters for puppet-neutron
#
class neutron::params {
  include openstacklib::defaults

  $client_package              = 'python3-neutronclient'
  $ovs_agent_service           = 'neutron-openvswitch-agent'
  $destroy_patch_ports_service = 'neutron-destroy-patch-ports'
  $linuxbridge_agent_service   = 'neutron-linuxbridge-agent'
  $macvtap_agent_service       = 'neutron-macvtap-agent'
  $opencontrail_plugin_package = 'neutron-plugin-contrail'
  $opencontrail_config_file    = '/etc/neutron/plugins/opencontrail/ContrailPlugin.ini'
  $nuage_config_file           = '/etc/neutron/plugins/nuage/plugin.ini'
  $dhcp_agent_service          = 'neutron-dhcp-agent'
  $metering_agent_service      = 'neutron-metering-agent'
  $l3_agent_service            = 'neutron-l3-agent'
  $metadata_agent_service      = 'neutron-metadata-agent'
  $ovn_metadata_agent_service  = 'neutron-ovn-metadata-agent'
  $ovn_agent_service           = 'neutron-ovn-agent'
  $bgp_dragent_service         = 'neutron-bgp-dragent'
  $bagpipe_bgp_package         = 'openstack-bagpipe-bgp'
  $bgpvpn_bagpipe_package      = 'python3-networking-bagpipe'
  $bgpvpn_bagpipe_service      = 'bagpipe-bgp'
  $bgpvpn_plugin_package       = 'python3-networking-bgpvpn'
  $l2gw_agent_service          = 'neutron-l2gw-agent'
  $sfc_package                 = 'python3-networking-sfc'
  $user                        = 'neutron'
  $group                       = 'neutron'
  $arista_plugin_package       = 'python3-networking-arista'
  $odl_plugin_package          = 'python3-networking-odl'

  case $facts['os']['family'] {
    'RedHat': {
      $package_name                       = 'openstack-neutron'
      $server_service                     = 'neutron-server'
      $server_package                     = false
      $api_package_name                   = false
      $api_service_name                   = false
      $rpc_package_name                   = false
      $rpc_service_name                   = false
      $ml2_server_package                 = 'openstack-neutron-ml2'
      $ovs_agent_package                  = 'openstack-neutron-openvswitch'
      $ovs_cleanup_service                = 'neutron-ovs-cleanup'
      $linuxbridge_agent_package          = 'openstack-neutron-linuxbridge'
      $sriov_nic_agent_service            = 'neutron-sriov-nic-agent'
      $sriov_nic_agent_package            = 'openstack-neutron-sriov-nic-agent'
      $macvtap_agent_package              = 'openstack-neutron-macvtap-agent'
      $dhcp_agent_package                 = false
      $metering_agent_package             = 'openstack-neutron-metering-agent'
      $vpnaas_agent_package               = 'openstack-neutron-vpnaas'
      $l2gw_agent_package                 = 'openstack-neutron-l2gw-agent'
      $l2gw_package                       = 'python3-networking-l2gw'
      $ovn_metadata_agent_package         = 'openstack-neutron-ovn-metadata-agent'
      $ovn_agent_package                  = 'openstack-neutron-ovn-agent'
      $dynamic_routing_package            = 'python3-neutron-dynamic-routing'
      $bgp_dragent_package                = 'openstack-neutron-bgp-dragent'
      $openswan_package                   = 'libreswan'
      $libreswan_package                  = 'libreswan'
      $metadata_agent_package             = false
      $l3_agent_package                   = false
      $neutron_wsgi_script_path           = '/var/www/cgi-bin/neutron'
      $neutron_wsgi_script_source         = '/usr/bin/neutron-api'
      $networking_baremetal_package       = 'python3-networking-baremetal'
      $networking_baremetal_agent_package = 'python3-ironic-neutron-agent'
      $networking_baremetal_agent_service = 'ironic-neutron-agent'
      $mlnx_agent_package                 = 'python3-networking-mlnx'
      $mlnx_plugin_package                = 'python3-networking-mlnx'
      $eswitchd_package                   = false
      $mlnx_agent_service                 = 'neutron-mlnx-agent'
      $eswitchd_service                   = 'eswitchd'
    }
    'Debian': {
      $package_name                       = 'neutron-common'
      if $facts['os']['name'] == 'Debian' {
        $ml2_server_package               = false
        $server_service                   = false
        $server_package                   = false
        $api_package_name                 = 'neutron-api'
        $api_service_name                 = 'neutron-api'
        $rpc_package_name                 = 'neutron-rpc-server'
        $rpc_service_name                 = 'neutron-rpc-server'
        $dynamic_routing_package          = 'python3-neutron-dynamic-routing'
      } else {
        $ml2_server_package = 'neutron-plugin-ml2'
        $server_service                   = 'neutron-server'
        $server_package                   = 'neutron-server'
        $api_package_name                 = false
        $api_service_name                 = false
        $rpc_package_name                 = false
        $rpc_service_name                 = false
        $dynamic_routing_package          = 'python3-neutron-dynamic-routing'
      }
      $bgp_dragent_package                = 'neutron-bgp-dragent'
      $ovs_agent_package                  = 'neutron-openvswitch-agent'
      $ovs_cleanup_service                = false
      $linuxbridge_agent_package          = 'neutron-linuxbridge-agent'
      $sriov_nic_agent_service            = 'neutron-sriov-agent'
      $sriov_nic_agent_package            = 'neutron-sriov-agent'
      $macvtap_agent_package              = 'neutron-macvtap-agent'
      $dhcp_agent_package                 = 'neutron-dhcp-agent'
      $metering_agent_package             = 'neutron-metering-agent'
      $vpnaas_agent_package               = 'python3-neutron-vpnaas'
      $openswan_package                   = 'strongswan'
      $libreswan_package                  = false
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
      $mlnx_agent_package                 = 'neutron-mlnx-agent'
      $mlnx_plugin_package                = 'python3-networking-mlnx'
      $eswitchd_package                   = 'networking-mlnx-eswitchd'
      $mlnx_agent_service                 = 'neutron-mlnx-agent'
      $eswitchd_service                   = 'networking-mlnx-eswitchd'
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
