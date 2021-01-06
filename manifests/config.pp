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
# [*plugin_linuxbridge_config*]
#   (optional) Manage configuration of linuxbridge_conf.ini
#
# [*plugin_nvp_config*]
#   (optional) Manage configuration of /etc/neutron/plugins/nicira/nvp.ini
#
# [*plugin_cisco_db_conn_config*]
#   (optional) Manage configuration of plugins/cisco/db_conn.ini
#
# [*plugin_cisco_l2network_config*]
#   (optional) Manage configuration of plugins/cisco/l2network_plugin.ini
#
# [*plugin_cisco_config*]
#   (optional) Manage configuration of cisco_plugins.ini
#
# [*plugin_midonet_config*]
#   (optional) Manage configuration of plugins/midonet/midonet.ini
#
# [*plugin_plumgrid_config*]
#   (optional) Manage configuration of plugins/plumgrid/plumgrid.ini
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
# [*plugin_nsx_config*]
#   (optional) Manage configuration of plugins/vmware/nsx.ini
#
# DEPRECATED PARAMETERS
#
# [*api_config*]
#   (optional) Manage configuration of api-paste.ini
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class neutron::config (
  $server_config                 = {},
  $api_paste_ini                 = {},
  $ovs_agent_config              = {},
  $sriov_agent_config            = {},
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
  $plugin_linuxbridge_config     = {},
  $plugin_cisco_db_conn_config   = {},
  $plugin_cisco_l2network_config = {},
  $plugin_cisco_config           = {},
  $plugin_midonet_config         = {},
  $plugin_plumgrid_config        = {},
  $plugin_opencontrail_config    = {},
  $plugin_nuage_config           = {},
  $plugin_ml2_config             = {},
  $plugin_nsx_config             = {},
  $plugin_nvp_config             = {},
  # DEPRECATED PARAMETERS
  $api_config                    = undef,
) {

  include neutron::deps

  if $api_config != undef {
    warning('The neutron::config::api_config parameter has been deprecated and \
will be removed in a future release. Use the api_paste_ini parameter instead.')
    $api_paste_ini_real = $api_config
  } else {
    $api_paste_ini_real = $api_paste_ini
  }

  validate_legacy(Hash, 'validate_hash', $server_config)
  validate_legacy(Hash, 'validate_hash', $api_paste_ini_real)
  validate_legacy(Hash, 'validate_hash', $ovs_agent_config)
  validate_legacy(Hash, 'validate_hash', $sriov_agent_config)
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
  validate_legacy(Hash, 'validate_hash', $plugin_linuxbridge_config)
  validate_legacy(Hash, 'validate_hash', $plugin_cisco_db_conn_config)
  validate_legacy(Hash, 'validate_hash', $plugin_cisco_l2network_config)
  validate_legacy(Hash, 'validate_hash', $plugin_cisco_config)
  validate_legacy(Hash, 'validate_hash', $plugin_midonet_config)
  validate_legacy(Hash, 'validate_hash', $plugin_plumgrid_config)
  validate_legacy(Hash, 'validate_hash', $plugin_opencontrail_config)
  validate_legacy(Hash, 'validate_hash', $plugin_nuage_config)
  validate_legacy(Hash, 'validate_hash', $plugin_ml2_config)
  validate_legacy(Hash, 'validate_hash', $plugin_nsx_config)
  validate_legacy(Hash, 'validate_hash', $plugin_nvp_config)

  create_resources('neutron_config', $server_config)
  create_resources('neutron_api_paste_ini', $api_paste_ini_real)
  create_resources('neutron_agent_ovs', $ovs_agent_config)
  create_resources('neutron_sriov_agent_config', $sriov_agent_config)
  create_resources('neutron_bgpvpn_bagpipe_config', $bgpvpn_bagpipe_config)
  create_resources('neutron_bgpvpn_service_config', $bgpvpn_service_config)
  create_resources('neutron_l2gw_agent_config', $l2gw_agent_config)
  create_resources('neutron_sfc_service_config', $sfc_service_config)
  create_resources('neutron_l3_agent_config', $l3_agent_config)
  create_resources('neutron_dhcp_agent_config', $dhcp_agent_config)
  create_resources('neutron_metadata_agent_config', $metadata_agent_config)
  create_resources('neutron_metering_agent_config', $metering_agent_config)
  create_resources('neutron_vpnaas_agent_config', $vpnaas_agent_config)
  create_resources('neutron_bgp_dragent_config', $bgp_dragent_config)
  create_resources('neutron_plugin_linuxbridge', $plugin_linuxbridge_config)
  create_resources('neutron_plugin_cisco_db_conn', $plugin_cisco_db_conn_config)
  create_resources('neutron_plugin_cisco_l2network', $plugin_cisco_l2network_config)
  create_resources('neutron_plugin_cisco', $plugin_cisco_config)
  create_resources('neutron_plugin_midonet', $plugin_midonet_config)
  create_resources('neutron_plugin_plumgrid', $plugin_plumgrid_config)
  create_resources('neutron_plugin_opencontrail', $plugin_opencontrail_config)
  create_resources('neutron_plugin_nuage', $plugin_nuage_config)
  create_resources('neutron_plugin_ml2', $plugin_ml2_config)
  create_resources('neutron_l2gw_service_config', $l2gw_service_config)
  create_resources('neutron_plugin_nsx', $plugin_nsx_config)
  create_resources('neutron_plugin_nvp', $plugin_nvp_config)
  create_resources('ovn_metadata_agent_config', $ovn_metadata_agent_config)
}
