#
class neutron::params {
  include ::openstacklib::defaults

  if($::osfamily == 'Redhat') {
    $nobody_user_group    = 'nobody'

    $package_name       = 'openstack-neutron'
    $server_package     = false
    $server_service     = 'neutron-server'
    $client_package     = 'python-neutronclient'

    $ml2_server_package = 'openstack-neutron-ml2'

    $ovs_agent_package   = false
    $ovs_agent_service   = 'neutron-openvswitch-agent'
    $ovs_server_package  = 'openstack-neutron-openvswitch'
    $ovs_cleanup_service = 'neutron-ovs-cleanup'
    $ovs_package         = 'openvswitch'
    $libnl_package       = 'libnl'
    $package_provider    = 'rpm'

    $linuxbridge_agent_package  = false
    $linuxbridge_agent_service  = 'neutron-linuxbridge-agent'
    $linuxbridge_server_package = 'openstack-neutron-linuxbridge'

    $sriov_nic_agent_service = 'neutron-sriov-nic-agent'
    $sriov_nic_agent_package = 'openstack-neutron-sriov-nic-agent'

    $bigswitch_lldp_package  = 'openstack-neutron-bigswitch-lldp'
    $bigswitch_agent_package = 'openstack-neutron-bigswitch-agent'
    $bigswitch_lldp_service  = 'neutron-bsn-lldp'
    $bigswitch_agent_service = 'neutron-bsn-agent'

    $cisco_server_package                   = 'openstack-neutron-cisco'
    $cisco_config_file                      = '/etc/neutron/plugins/cisco/cisco_plugins.ini'
    # Add templated Cisco Nexus ML2 config to confdir
    $cisco_ml2_mech_cisco_nexus_config_file = '/etc/neutron/conf.d/neutron-server/ml2_mech_cisco_nexus.conf'

    $opencontrail_plugin_package = 'neutron-plugin-contrail'
    $opencontrail_config_file    = '/etc/neutron/plugins/opencontrail/ContrailPlugin.ini'

    $midonet_server_package = 'python-networking-midonet'
    $midonet_config_file    = '/etc/neutron/plugins/midonet/midonet.ini'

    $ovn_plugin_package = 'python-networking-ovn'

    $plumgrid_plugin_package    = 'networking-plumgrid'
    $plumgrid_pythonlib_package = 'plumgrid-pythonlib'
    $plumgrid_config_file       = '/etc/neutron/plugins/plumgrid/plumgrid.ini'

    $nvp_server_package = 'openstack-neutron-nicira'

    $nuage_config_file    = '/etc/neutron/plugins/nuage/plugin.ini'

    $dhcp_agent_package = false
    $dhcp_agent_service = 'neutron-dhcp-agent'

    $dnsmasq_packages   = ['dnsmasq', 'dnsmasq-utils']

    $lbaasv2_agent_package = 'openstack-neutron-lbaas'
    $lbaasv2_agent_service = 'neutron-lbaasv2-agent'

    $haproxy_package   = 'haproxy'

    $metering_agent_package = 'openstack-neutron-metering-agent'
    $metering_agent_service = 'neutron-metering-agent'

    $vpnaas_agent_package = 'openstack-neutron-vpnaas'
    $vpnaas_agent_service = 'neutron-vpn-agent'
    if $::operatingsystemrelease =~ /^7.*/ or $::operatingsystem == 'Fedora' {
      $openswan_package     = 'libreswan'
    } else {
      $openswan_package     = 'openswan'
    }
    $libreswan_package     = 'libreswan'

    $l3_agent_package   = false
    $l3_agent_service   = 'neutron-l3-agent'

    $fwaas_package      = 'openstack-neutron-fwaas'

    $metadata_agent_service = 'neutron-metadata-agent'

    $cliff_package      = 'python-cliff'

    $kernel_headers     = "linux-headers-${::kernelrelease}"

  } elsif($::osfamily == 'Debian') {

    $nobody_user_group    = 'nogroup'

    $package_name       = 'neutron-common'
    $server_package     = 'neutron-server'
    $server_service     = 'neutron-server'
    $client_package     = 'python-neutronclient'

    if $::os_package_type =='debian' {
      $ml2_server_package = false
    } else {
      $ml2_server_package = 'neutron-plugin-ml2'
    }

    $ovs_agent_package   = 'neutron-openvswitch-agent'
    $ovs_agent_service   = 'neutron-openvswitch-agent'

    $ovs_server_package  = 'neutron-plugin-openvswitch'
    $ovs_cleanup_service = false
    $ovs_package         = 'openvswitch-switch'
    $libnl_package       = 'libnl1'
    $package_provider    = 'dpkg'

    $linuxbridge_agent_package  = 'neutron-linuxbridge-agent'
    $linuxbridge_agent_service  = 'neutron-linuxbridge-agent'
    $linuxbridge_server_package = 'neutron-plugin-linuxbridge'

    $sriov_nic_agent_service = 'neutron-sriov-agent'
    $sriov_nic_agent_package = 'neutron-sriov-agent'

    $cisco_server_package                   = 'neutron-plugin-cisco'
    $cisco_config_file                      = '/etc/neutron/plugins/cisco/cisco_plugins.ini'
    $cisco_ml2_mech_cisco_nexus_config_file = '/etc/neutron/plugins/ml2/ml2_mech_cisco_nexus.ini'

    $opencontrail_plugin_package = 'neutron-plugin-contrail'
    $opencontrail_config_file    = '/etc/neutron/plugins/opencontrail/ContrailPlugin.ini'

    $midonet_server_package      = 'python-networking-midonet'
    $midonet_server_package_ext  = 'python-networking-midonet-ext'
    $midonet_config_file         = '/etc/neutron/plugins/midonet/midonet.ini'

    $ovn_plugin_package = 'python-networking-ovn'

    $plumgrid_plugin_package    = 'networking-plumgrid'
    $plumgrid_pythonlib_package = 'plumgrid-pythonlib'
    $plumgrid_config_file       = '/etc/neutron/plugins/plumgrid/plumgrid.ini'

    $nvp_server_package = 'neutron-plugin-nicira'

    $nuage_config_file    = '/etc/neutron/plugins/nuage/plugin.ini'

    $dhcp_agent_package = 'neutron-dhcp-agent'
    $dhcp_agent_service = 'neutron-dhcp-agent'

    $lbaasv2_agent_package = 'neutron-lbaasv2-agent'
    $lbaasv2_agent_service = 'neutron-lbaasv2-agent'

    $haproxy_package   = 'haproxy'

    $metering_agent_package = 'neutron-metering-agent'
    $metering_agent_service = 'neutron-metering-agent'

    $vpnaas_agent_package = 'neutron-vpn-agent'
    $vpnaas_agent_service = 'neutron-vpn-agent'

    $openswan_package     = 'openswan'
    $libreswan_package    = false

    $metadata_agent_package = 'neutron-metadata-agent'
    $metadata_agent_service = 'neutron-metadata-agent'

    $dnsmasq_packages   = ['dnsmasq-base', 'dnsmasq-utils']

    $isc_dhcp_packages  = ['isc-dhcp-server']

    $l3_agent_package   = 'neutron-l3-agent'
    $l3_agent_service   = 'neutron-l3-agent'

    $fwaas_package      = 'python-neutron-fwaas'

    $cliff_package      = 'python-cliff'
    $kernel_headers     = "linux-headers-${::kernelrelease}"
  } else {

    fail("Unsupported osfamily ${::osfamily}")

  }
}
