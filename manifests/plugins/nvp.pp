#
# Configure the Nicira NVP plugin for neutron.
#
# === Parameters
#
# [*nvp_controllers*]
#   The password for connection to VMware vCenter server.
#
# [*nvp_user*]
#   The user name for NVP controller.
#
# [*nvp_password*]
#   The password for NVP controller
#
# [*default_tz_uuid*]
#   UUID of the pre-existing default NVP Transport zone to be used for creating
#   tunneled isolated "Neutron" networks. This option MUST be specified.
#
# [*default_l3_gw_service_uuid*]
#   (Optional) UUID for the default l3 gateway service to use with this cluster.
#   To be specified if planning to use logical routers with external gateways.
#   Defaults to $::os_service_default.
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
class neutron::plugins::nvp (
  $default_tz_uuid,
  $nvp_controllers,
  $nvp_user,
  $nvp_password,
  $default_l3_gw_service_uuid = $::os_service_default,
  $package_ensure    = 'present',
  $purge_config      = false,
) {

  include ::neutron::deps
  include ::neutron::params

  Package['neutron'] -> Package['neutron-plugin-nvp']

  package { 'neutron-plugin-nvp':
    ensure => $package_ensure,
    name   => $::neutron::params::nvp_server_package,
    tag    => ['neutron-package', 'openstack'],
  }

  validate_array($nvp_controllers)

  resources { 'neutron_plugin_nvp':
    purge => $purge_config,
  }

  neutron_plugin_nvp {
    'DEFAULT/default_tz_uuid':            value => $default_tz_uuid;
    'DEFAULT/nvp_controllers':            value => join($nvp_controllers, ',');
    'DEFAULT/nvp_user':                   value => $nvp_user;
    'DEFAULT/nvp_password':               value => $nvp_password, secret => true;
    'DEFAULT/default_l3_gw_service_uuid': value => $default_l3_gw_service_uuid;
    'nvp/metadata_mode':                  value => 'access_network';
  }

  if $::neutron::core_plugin != 'neutron.plugins.nicira.NeutronPlugin.NvpPluginV2' {
    fail('nvp plugin should be the core_plugin in neutron.conf')
  }

  # In RH, this link is used to start Neutron process but in Debian, it's used only
  # to manage database synchronization.
  file {'/etc/neutron/plugin.ini':
    ensure => link,
    target => '/etc/neutron/plugins/nicira/nvp.ini',
    tag    => 'neutron-config-file',
  }

}
