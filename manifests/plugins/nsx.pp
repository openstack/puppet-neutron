#
# Configure the VMware NSX plugin for neutron.
#
# === Parameters
#
# [*default_overlay_tz*]
#   (Optional) Name or UUID of the default overlay Transport Zone to be used
#   for creating tunneled isolated "Neutron" networks. This option MUST be
#   specified.
#   Defaults to $::os_service_default
#
# [*default_vlan_tz*]
#   (Optional) Name or UUID of the default VLAN Transport Zone to be used for
#   creating VLAN networks.
#   Defaults to $::os_service_default
#
# [*default_bridge_cluster*]
#   (Optional) Name or UUID of the default NSX bridge cluster that will be
#   used to perform L2 gateway bridging between VXLAN and VLAN networks.
#   Defaults to $::os_service_default
#
# [*default_tier0_router*]
#   (Optional) Name or UUID of the pre-created default tier0 (provider) router
#   on NSX backend. This option is used to create external networks and MUST be
#   specified.
#   Defaults to $::os_service_default
#
# [*nsx_api_managers*]
#   (Optional) Comma separated NSX manager IP addresses. This option MUST be
#   specified.
#   Defaults to $::os_service_default
#
# [*nsx_api_user*]
#   (Optional) The username for NSX manager.
#   Defaults to $::os_service_default
#
# [*nsx_api_password*]
#   (Optional) The password for NSX manager.
#   Defaults to $::os_service_default
#
# [*dhcp_profile*]
#   (Optional) Name or UUID of the pre-created DHCP profile on NSX backend to
#   support native DHCP. This option MUST be specified if native_dhcp_metadata
#   is True.
#   Defaults to $::os_service_default
#
# [*dhcp_relay_service*]
#   (Optional) This is the name or UUID of the NSX relay service that will be
#   used to enable DHCP relay on router ports.
#   Defaults to $::os_service_default
#
# [*metadata_proxy*]
#   (Optional) Name or UUID of the pre-created Metadata Proxy on NSX backend.
#   This option MUST be specified if native_dhcp_metadata is True.
#   Defaults to $::os_service_default
#
# [*native_dhcp_metadata*]
#   (Optional) Flag to enable native DHCP and Metadata.
#   Defaults to $::os_service_default
#
# [*package_ensure*]
#   (Optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified config options
#   in the nvp config.
#   Defaults to false.
#
# DEPRECATED
#
# [*dhcp_profile_uuid*]
#   (DEPRECATED) UUID of the pre-created DHCP profile on NSX backend to support
#   native DHCP.
#
# [*metadata_proxy_uuid*]
#   (DEPRECATED) UUID of the pre-created Metadata Proxy on NSX backend.
#
class neutron::plugins::nsx (
  $default_overlay_tz     = $::os_service_default,
  $default_vlan_tz        = $::os_service_default,
  $default_bridge_cluster = $::os_service_default,
  $default_tier0_router   = $::os_service_default,
  $nsx_api_managers       = $::os_service_default,
  $nsx_api_user           = $::os_service_default,
  $nsx_api_password       = $::os_service_default,
  $dhcp_profile           = $::os_service_default,
  $dhcp_relay_service     = $::os_service_default,
  $metadata_proxy         = $::os_service_default,
  $native_dhcp_metadata   = $::os_service_default,
  $package_ensure         = 'present',
  $purge_config           = false,
  # DEPRECATED
  $dhcp_profile_uuid      = undef,
  $metadata_proxy_uuid    = undef,
) {

  include neutron::deps
  include neutron::params

  package { 'vmware-nsx':
    ensure => $package_ensure,
    name   => $::neutron::params::nsx_plugin_package,
    tag    => ['openstack', 'neutron-package'],
  }

  file { '/etc/neutron/plugins/vmware':
    ensure => directory,
    tag    => 'neutron-config-file',
  }

  file { $::neutron::params::nsx_config_file:
    ensure  => file,
    owner   => 'root',
    group   => $::neutron::params::group,
    require => File['/etc/neutron/plugins/vmware'],
    mode    => '0640',
    tag     => 'neutron-config-file',
  }

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path  => '/etc/default/neutron-server',
      match => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line  => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::nsx_config_file}",
      tag   => 'neutron-file-line',
    }
  }

  if $::osfamily == 'Redhat' {
    file { '/etc/neutron/plugin.ini':
      ensure  => link,
      require => File[$::neutron::params::nsx_config_file],
      target  => $::neutron::params::nsx_config_file,
      tag     => 'neutron-config-file',
    }
  }

  if $dhcp_profile_uuid or $metadata_proxy_uuid {
    warning('dhcp_profile_uuid and $metadata_proxy_uuid are deprecated and will be removed in the future')
  }

  resources { 'neutron_plugin_nsx':
    purge => $purge_config,
  }

  neutron_plugin_nsx {
    'nsx_v3/default_overlay_tz':       value => $default_overlay_tz;
    'nsx_v3/default_vlan_tz':          value => $default_vlan_tz;
    'nsx_v3/default_bridge_cluster':   value => $default_bridge_cluster;
    'nsx_v3/default_tier0_router':     value => $default_tier0_router;
    'nsx_v3/nsx_api_managers':         value => $nsx_api_managers;
    'nsx_v3/nsx_api_user':             value => $nsx_api_user;
    'nsx_v3/nsx_api_password':         value => $nsx_api_password;
    'nsx_v3/dhcp_profile':             value => pick($dhcp_profile_uuid, $dhcp_profile);
    'nsx_v3/dhcp_relay_service':       value => $dhcp_relay_service;
    'nsx_v3/metadata_proxy':           value => pick($metadata_proxy_uuid, $metadata_proxy);
    'nsx_v3/native_dhcp_metadata':     value => $native_dhcp_metadata;
  }

  if ($::neutron::core_plugin != 'vmware_nsx.plugin.NsxV3Plugin') and
    ($::neutron::core_plugin != 'nsx') {
    fail('VMware NSX plugin should be the core_plugin in neutron.conf')
  }
}
