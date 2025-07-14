# == Class: neutron::config
#
# This class is used to manage arbitrary Neutron configurations.
#
# example xxx_config
#   (optional) Allow configuration of arbitrary Neutron xxx specific configurations.
#   The value is a hash of neutron_config resources. Example:
#   server_config =>
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#
#   NOTE: { 'DEFAULT/foo': value => 'fooValue'; 'DEFAULT/bar': value => 'barValue'} is invalid.
#
#   In yaml format, Example:
#   server_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
# === Parameters
#
# [*server_config*]
#   (optional) Manage configuration of neutron.conf
#
# [*api_paste_ini*]
#   (optional) Manage configuration of api-paste.ini
#
# [*rootwrap_config*]
#   (optional) Allow configuration of rootwrap.conf configurations.
#
# [*ovs_agent_config*]
#   (optional) Manage configuration of openvswitch_agent.ini
#
# [*sriov_agent_config*]
#   (optional) Manage configuration of sriov_agent.ini
#
# [*ovn_agent_config*]
#   (optional) Manage configuration of ovn_agent.ini
#
# [*macvtap_agent_config*]
#   (optional) Manage configuration of macvtap_agent.ini
#
# [*bgpvpn_bagpipe_config*]
#   (optional) Manage configuration of bagpipe-bgp bgp.conf
#
# [*bgpvpn_service_config*]
#   (optional) Manage configuration of networking_bgpvpn.conf
#
# [*l2gw_agent_config*]
#   (optional) Manage configuration of l2gateway_agent.ini
#
# [*l2gw_service_config*]
#   (optional) Manage configuration of l2gw_plugin.ini
#
# [*sfc_service_config*]
#   (optional) Manage configuration of networking-sfc.conf
#
# [*l3_agent_config*]
#   (optional) Manage configuration of l3_agent.ini
#
# [*dhcp_agent_config*]
#   (optional) Manage configuration of dhcp_agent.ini
#
# [*metadata_agent_config*]
#   (optional) Manage configuration of metadata_agent.ini
#
# [*ovn_metadata_agent_config*]
#   (optional) Manage configuration of neutron_ovn_metadata_agent.ini
#
# [*metering_agent_config*]
#   (optional) Manage configuration of metering_agent.ini
#
# [*fwaas_agent_config*]
#   (optional) Manage configuration of fwaas_driver.ini
#
# [*fwaas_service_config*]
#   (optional) Manage configuration of neutron_fwaas.conf
#
# [*vpnaas_agent_config*]
#   (optional) Manage configuration of vpn_agent.ini
#
# [*vpnaas_service_config*]
#   (optional) Manage configuration of neutron_vpnaas.conf
#
# [*ovn_vpn_agent_config*]
#   (optional) Manage configuration of ovn_vpn_agent.ini
#
# [*taas_service_config*]
#   (optional) Manage configuration of taas_plugin.ini
#
# [*bgp_dragent_config*]
#   (optional) Manage configuration of bgp_dragent.ini
#
# [*plugin_ml2_config*]
#   (optional) Manage configuration of ml2_conf.ini
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class neutron::config (
  Hash $server_config                 = {},
  Hash $api_paste_ini                 = {},
  Hash $rootwrap_config               = {},
  Hash $ovs_agent_config              = {},
  Hash $ovn_agent_config              = {},
  Hash $sriov_agent_config            = {},
  Hash $macvtap_agent_config          = {},
  Hash $bgpvpn_bagpipe_config         = {},
  Hash $bgpvpn_service_config         = {},
  Hash $l2gw_agent_config             = {},
  Hash $l2gw_service_config           = {},
  Hash $sfc_service_config            = {},
  Hash $l3_agent_config               = {},
  Hash $dhcp_agent_config             = {},
  Hash $metadata_agent_config         = {},
  Hash $ovn_metadata_agent_config     = {},
  Hash $metering_agent_config         = {},
  Hash $fwaas_agent_config            = {},
  Hash $fwaas_service_config          = {},
  Hash $vpnaas_agent_config           = {},
  Hash $vpnaas_service_config         = {},
  Hash $ovn_vpn_agent_config          = {},
  Hash $taas_service_config           = {},
  Hash $bgp_dragent_config            = {},
  Hash $plugin_ml2_config             = {},
) {

  include neutron::deps

  create_resources('neutron_config', $server_config)
  create_resources('neutron_api_paste_ini', $api_paste_ini)
  create_resources('neutron_rootwrap_config', $rootwrap_config)
  create_resources('neutron_agent_ovs', $ovs_agent_config)
  create_resources('neutron_agent_ovn', $ovn_agent_config)
  create_resources('neutron_sriov_agent_config', $sriov_agent_config)
  create_resources('neutron_agent_macvtap', $macvtap_agent_config)
  create_resources('neutron_bgpvpn_bagpipe_config', $bgpvpn_bagpipe_config)
  create_resources('neutron_bgpvpn_service_config', $bgpvpn_service_config)
  create_resources('neutron_l2gw_agent_config', $l2gw_agent_config)
  create_resources('neutron_l2gw_service_config', $l2gw_service_config)
  create_resources('neutron_sfc_service_config', $sfc_service_config)
  create_resources('neutron_l3_agent_config', $l3_agent_config)
  create_resources('neutron_dhcp_agent_config', $dhcp_agent_config)
  create_resources('neutron_metadata_agent_config', $metadata_agent_config)
  create_resources('ovn_metadata_agent_config', $ovn_metadata_agent_config)
  create_resources('neutron_metering_agent_config', $metering_agent_config)
  create_resources('neutron_fwaas_agent_config', $fwaas_agent_config)
  create_resources('neutron_fwaas_service_config', $fwaas_service_config)
  create_resources('neutron_vpnaas_agent_config', $vpnaas_agent_config)
  create_resources('neutron_vpnaas_service_config', $vpnaas_service_config)
  create_resources('neutron_ovn_vpn_agent_config', $ovn_vpn_agent_config)
  create_resources('neutron_taas_service_config', $taas_service_config)
  create_resources('neutron_bgp_dragent_config', $bgp_dragent_config)
  create_resources('neutron_plugin_ml2', $plugin_ml2_config)
}
