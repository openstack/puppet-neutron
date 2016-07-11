# == Class: neutron::deps
#
#  neutron anchors and dependency management
#
class neutron::deps {
  # Setup anchors for install, config and service phases of the module.  These
  # anchors allow external modules to hook the begin and end of any of these
  # phases.  Package or service management can also be replaced by ensuring the
  # package is absent or turning off service management and having the
  # replacement depend on the appropriate anchors.  When applicable, end tags
  # should be notified so that subscribers can determine if installation,
  # config or service state changed and act on that if needed.
  anchor { 'neutron::install::begin': }
  -> Package<| tag == 'neutron-package'|>
  ~> anchor { 'neutron::install::end': }
  -> anchor { 'neutron::config::begin': }
  -> File<| tag == 'neutron-config-file' |>
  ~> anchor { 'neutron::config::end': }
  -> anchor { 'neutron::db::begin': }
  -> anchor { 'neutron::db::end': }
  ~> anchor { 'neutron::dbsync::begin': }
  -> anchor { 'neutron::dbsync::end': }
  ~> anchor { 'neutron::service::begin': }
  ~> Service<| tag == 'neutron-service' |>
  ~> anchor { 'neutron::service::end': }

  # Ensure files are modified in the config block
  Anchor['neutron::config::begin']
  -> File_line<| tag == 'neutron-file-line' |>
  ~> Anchor['neutron::config::end']

  # Ensure all files are in place before modifying them
  File<| tag == 'neutron-config-file' |> -> File_line<| tag == 'neutron-file-line' |>

  # All other inifile providers need to be processed in the config block
  Anchor['neutron::config::begin'] -> Neutron_agent_linuxbridge<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_agent_ovs<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_api_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_api_paste_ini<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_dhcp_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_fwaas_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_l3_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_lbaas_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_lbaas_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_lbaas_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_metadata_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_metering_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_cisco_credentials<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_cisco_db_conn<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_cisco<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_cisco_l2network<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_linuxbridge<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_midonet<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_ml2<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_nuage<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_nvp<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_opencontrail<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_plumgrid<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_sriov<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plumlib_plumgrid<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_sriov_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_vpnaas_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_vpnaas_service_config<||> ~> Anchor['neutron::config::end']

  # Support packages need to be installed in the install phase, but we don't
  # put them in the chain above because we don't want any false dependencies
  # between packages with the neutron-package tag and the neutron-support-package
  # tag.  Note: the package resources here will have a 'before' relationshop on
  # the neutron::install::end anchor.  The line between neutron-support-package and
  # neutron-package should be whether or not neutron services would need to be
  # restarted if the package state was changed.
  Anchor['neutron::install::begin']
  -> Package<| tag == 'neutron-support-package'|>
  -> Anchor['neutron::install::end']

  Anchor['neutron::service::end'] -> Neutron_l3_ovs_bridge<||>
  Anchor['neutron::service::end'] -> Neutron_network<||>
  Anchor['neutron::service::end'] -> Neutron_port<||>
  Anchor['neutron::service::end'] -> Neutron_router<||>
  Anchor['neutron::service::end'] -> Neutron_subnet<||>

  # Installation or config changes will always restart services.
  Anchor['neutron::install::end'] ~> Anchor['neutron::service::begin']
  Anchor['neutron::config::end']  ~> Anchor['neutron::service::begin']
}
