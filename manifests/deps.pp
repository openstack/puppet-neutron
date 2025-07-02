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
  Anchor['neutron::config::begin'] -> Neutron_api_paste_ini<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_api_uwsgi_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_agent_macvtap<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_agent_ovs<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_agent_ovn<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_bgpvpn_bagpipe_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_bgpvpn_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_sfc_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_dhcp_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_l2gw_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_l3_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_metadata_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_metering_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_bgp_dragent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_l2gw_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_plugin_ml2<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_sriov_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_fwaas_agent_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_fwaas_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_vpnaas_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_vpnaas_service_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Neutron_rootwrap_config<||> ~> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Ovn_metadata_agent_config<||> -> Anchor['neutron::config::end']
  Anchor['neutron::config::begin'] -> Ironic_neutron_agent_config<||> -> Anchor['neutron::config::end']

  # Support packages need to be installed in the install phase, but we don't
  # put them in the chain above because we don't want any false dependencies
  # between packages with the neutron-package tag and the neutron-support-package
  # tag.  Note: the package resources here will have a 'before' relationship on
  # the neutron::install::end anchor.  The line between neutron-support-package and
  # neutron-package should be whether or not neutron services would need to be
  # restarted if the package state was changed.
  Anchor['neutron::install::begin']
  -> Package<| tag == 'neutron-support-package'|>
  -> Anchor['neutron::install::end']

  # ml2 plugin packages should be install after we start actual configuration,
  # because the configuration for ml2 plugin base should be applied before
  # ml2 plugin packages are installed
  Anchor['neutron::install::begin']
  -> Package<| tag == 'neutron-plugin-ml2-package'|>
  ~> Anchor['neutron::config::end']

  # We need openstackclient before marking service end so that neutron
  # will have clients available to create resources. This tag handles the
  # openstackclient but indirectly since the client is not available in
  # all catalogs that don't need the client class (like many spec tests)
  Package<| tag == 'openstackclient'|>
  -> Anchor['neutron::service::end']

  # Installation or config changes will always restart services.
  Anchor['neutron::install::end'] ~> Anchor['neutron::service::begin']
  Anchor['neutron::config::end']  ~> Anchor['neutron::service::begin']
}
