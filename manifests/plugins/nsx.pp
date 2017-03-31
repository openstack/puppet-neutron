#
# Configure the VMware NSX plugin for neutron.
#
# === Parameters
#
# [*default_overlay_tz*]
#   UUID of the default overlay Transport Zone to be used for creating
#   tunneled isolated "Neutron" networks. This option MUST be specified.
#
# [*default_tier0_router*]
#   UUID of the pre-created default tier0 (provider) router on NSX backend.
#   This option is used to create external networks and MUST be specified.
#
# [*nsx_api_managers*]
#   Comma separated NSX manager IP addresses. This option MUST be specified.
#
# [*nsx_api_user*]
#   The username for NSX manager.
#
# [*nsx_api_password*]
#   The password for NSX manager.
#
# [*dhcp_profile_uuid*]
#   UUID of the pre-created DHCP profile on NSX backend to support native DHCP.
#   This option MUST be specified if native_dhcp_metadata is True.
#
# [*metadata_proxy_uuid*]
#   UUID of the pre-created Metadata Proxy on NSX backend. This option MUST
#   be specified if native_dhcp_metadata is True.
#
# [*native_dhcp_metadata*]
#   Flag to enable native DHCP and Metadata.
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the nvp config.
#   Defaults to false.
#
class neutron::plugins::nsx (
  $default_overlay_tz   = $::os_service_default,
  $default_tier0_router = $::os_service_default,
  $nsx_api_managers     = $::os_service_default,
  $nsx_api_user         = $::os_service_default,
  $nsx_api_password     = $::os_service_default,
  $dhcp_profile_uuid    = $::os_service_default,
  $metadata_proxy_uuid  = $::os_service_default,
  $native_dhcp_metadata = $::os_service_default,
  $package_ensure       = 'present',
  $purge_config         = false,
) {

  include ::neutron::deps
  include ::neutron::params

  file { '/etc/neutron/plugins/vmware':
    ensure => directory,
    tag    => 'neutron-config-file',
  }

  file { $::neutron::params::nsx_config_file:
    ensure  => file,
    owner   => 'root',
    group   => 'neutron',
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


  resources { 'neutron_plugin_nsx':
    purge => $purge_config,
  }

  neutron_plugin_nsx {
    'nsx_v3/default_overlay_tz':   value => $default_overlay_tz;
    'nsx_v3/default_tier0_router': value => $default_tier0_router;
    'nsx_v3/nsx_api_managers':     value => $nsx_api_managers;
    'nsx_v3/nsx_api_user':         value => $nsx_api_user;
    'nsx_v3/nsx_api_password':     value => $nsx_api_password;
    'nsx_v3/dhcp_profile_uuid':    value => $dhcp_profile_uuid;
    'nsx_v3/metadata_proxy_uuid':  value => $metadata_proxy_uuid;
    'nsx_v3/native_dhcp_metadata': value => $native_dhcp_metadata;
  }

  if ($::neutron::core_plugin != 'vmware_nsx.plugin.NsxV3Plugin') and
    ($::neutron::core_plugin != 'nsx') {
    fail('VMware NSX plugin should be the core_plugin in neutron.conf')
  }
}
