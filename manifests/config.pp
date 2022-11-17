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
# [*ovs_agent_config*]
#   (optional) Manage configuration of openvswitch_agent.ini
#
# [*sriov_agent_config*]
#   (optional) Manage configuration of sriov_agent.ini
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
#   (optional) Manage configuration of networking-ovn metadata_agent.ini
#
# [*metering_agent_config*]
#   (optional) Manage configuration of metering_agent.ini
#
# [*vpnaas_agent_config*]
#   (optional) Manage configuration of vpn_agent.ini
#
# [*bgp_dragent_config*]
#   (optional) Manage configuration of bgp_dragent.ini
#
# [*plugin_opencontrail_config*]
#   (optional) Manage configuration of plugins/opencontrail/ContrailPlugin.ini
#
# [*plugin_nuage_config*]
#   (optional) Manage configuration of plugins/nuage/plugin.ini
#
# [*plugin_ml2_config*]
#   (optional) Manage configuration of ml2_conf.ini
#
# DEPRECATED PARAMETERS
#
# [*linuxbridge_agent_config*]
#   (optional) Manage configuration of linuxbridge_agent.ini
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class neutron::config (
  $server_config                 = {},
  $api_paste_ini                 = {},
  $ovs_agent_config              = {},
  $sriov_agent_config            = {},
  $macvtap_agent_config          = {},
  $bgpvpn_bagpipe_config         = {},
  $bgpvpn_service_config         = {},
  $l2gw_agent_config             = {},
  $l2gw_service_config           = {},
  $sfc_service_config            = {},
  $l3_agent_config               = {},
  $dhcp_agent_config             = {},
  $metadata_agent_config         = {},
  $ovn_metadata_agent_config     = {},
  $metering_agent_config         = {},
  $vpnaas_agent_config           = {},
  $bgp_dragent_config            = {},
  $plugin_opencontrail_config    = {},
  $plugin_nuage_config           = {},
  $plugin_ml2_config             = {},
  # DEPRECATED PARAMETERS
  $linuxbridge_agent_config      = undef,
) {

  include neutron::deps

  if $linuxbridge_agent_config != undef {
    warning('The linuxbridge_agent_config parameter is deprecated.')
    $linuxbridge_agent_config_real = $linuxbridge_agent_config
  } else {
    $linuxbridge_agent_config_real = {}
  }

  validate_legacy(Hash, 'validate_hash', $server_config)
  validate_legacy(Hash, 'validate_hash', $api_paste_ini)
  validate_legacy(Hash, 'validate_hash', $ovs_agent_config)
  validate_legacy(Hash, 'validate_hash', $sriov_agent_config)
  validate_legacy(Hash, 'validate_hash', $linuxbridge_agent_config_real)
  validate_legacy(Hash, 'validate_hash', $macvtap_agent_config)
  validate_legacy(Hash, 'validate_hash', $bgpvpn_bagpipe_config)
  validate_legacy(Hash, 'validate_hash', $bgpvpn_service_config)
  validate_legacy(Hash, 'validate_hash', $l2gw_agent_config)
  validate_legacy(Hash, 'validate_hash', $l2gw_service_config)
  validate_legacy(Hash, 'validate_hash', $sfc_service_config)
  validate_legacy(Hash, 'validate_hash', $l3_agent_config)
  validate_legacy(Hash, 'validate_hash', $dhcp_agent_config)
  validate_legacy(Hash, 'validate_hash', $metadata_agent_config)
  validate_legacy(Hash, 'validate_hash', $ovn_metadata_agent_config)
  validate_legacy(Hash, 'validate_hash', $metering_agent_config)
  validate_legacy(Hash, 'validate_hash', $vpnaas_agent_config)
  validate_legacy(Hash, 'validate_hash', $bgp_dragent_config)
  validate_legacy(Hash, 'validate_hash', $plugin_opencontrail_config)
  validate_legacy(Hash, 'validate_hash', $plugin_nuage_config)
  validate_legacy(Hash, 'validate_hash', $plugin_ml2_config)

  create_resources('neutron_config', $server_config)
  create_resources('neutron_api_paste_ini', $api_paste_ini)
  create_resources('neutron_agent_ovs', $ovs_agent_config)
  create_resources('neutron_sriov_agent_config', $sriov_agent_config)
  create_resources('neutron_agent_linuxbridge', $linuxbridge_agent_config_real)
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
  create_resources('neutron_vpnaas_agent_config', $vpnaas_agent_config)
  create_resources('neutron_bgp_dragent_config', $bgp_dragent_config)
  create_resources('neutron_plugin_opencontrail', $plugin_opencontrail_config)
  create_resources('neutron_plugin_nuage', $plugin_nuage_config)
  create_resources('neutron_plugin_ml2', $plugin_ml2_config)
}
