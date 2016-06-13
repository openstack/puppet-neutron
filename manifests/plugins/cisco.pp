
#
# Configure the cisco neutron plugin
# More info available here:
# https://wiki.openstack.org/wiki/Cisco-neutron
#
# === Parameters
#
# [*database_pass*]
# The password that will be used to connect to the db
#
# [*keystone_password*]
# The password for the supplied username
#
# [*database_name*]
# The name of the db table to use
# Defaults to neutron
#
# [*database_user*]
# The user that will be used to connect to the db
# Defaults to neutron
#
# [*database_host*]
# The address or hostname of the database
# Defaults to 127.0.0.1
#
# [*keystone_username*]
# The admin username for the plugin to use
# Defaults to neutron
#
# [*keystone_auth_url*]
# The url against which to authenticate
# Defaults to http://127.0.0.1:35357/v2.0/
#
# [*keystone_tenant*]
# The tenant the supplied user has admin privs in
# Defaults to services
#
# [*vswitch_plugin*]
# (optional) The openvswitch plugin to use
# Defaults to ovs_neutron_plugin.OVSNeutronPluginV2
#
# [*nexus_plugin*]
# (optional) The nexus plugin to use
# Defaults to $::os_service_default. This will not set a nexus plugin to use
# Can be set to neutron.plugins.cisco.nexus.cisco_nexus_plugin_v2.NexusPlugin
#
# [*vlan_start*]
#  (optional) First VLAN for private networks.
#  Defaults to '100'.
#
# [*vlan_end*]
#  (optional) Last VLAN for private networks.
#  Defaults to '3000'.
#
# [*vlan_name_prefix*]
#  (optional) VLAN Name prefix
#  Defaults to 'q-'
#
# [*model_class*]
#  (optional) Model Class
#  Defaults to 'neutron.plugins.cisco.models.virt_phy_sw_v2.VirtualPhysicalSwitchModelV2'
#
# [*max_ports*]
#  (optional) Number max of ports
#  Defaults to '100'
#
# [*max_port_profiles*]
#  (optional) Number max of port profiles
#  Defaults to '65568'
#
# [*manager_class*]
#  (optional) Manager Class
#  Defaults to 'neutron.plugins.cisco.segmentation.l2network_vlan_mgr_v2.L2NetworkVLANMgr'
#
# [*max_networks*]
#  (optional)
#  Defaults to '65568'
#
# [*package_ensure*]
#  (optional) the ensure state of the package resource
#  Defaults to 'present'
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the cisco config.
#   Defaults to false.
#
# Other parameters are currently not used by the plugin and
# can be left unchanged, but in grizzly the plugin will fail
# to launch if they are not there. The config for Havana will
# move to a single config file and this will be simplified.

class neutron::plugins::cisco(
  $keystone_password,
  $database_pass,

  # Database connection
  $database_name     = 'neutron',
  $database_user     = 'neutron',
  $database_host     = '127.0.0.1',

  # Keystone connection
  $keystone_username = 'neutron',
  $keystone_tenant   = 'services',
  $keystone_auth_url = 'http://127.0.0.1:35357/v2.0/',

  $vswitch_plugin = 'neutron.plugins.openvswitch.ovs_neutron_plugin.OVSNeutronPluginV2',
  $nexus_plugin   = $::os_service_default,

  # Plugin minimum configuration
  $vlan_start        = '100',
  $vlan_end          = '3000',
  $vlan_name_prefix  = 'q-',
  $model_class       = 'neutron.plugins.cisco.models.virt_phy_sw_v2.VirtualPhysicalSwitchModelV2',
  $max_ports         = '100',
  $max_port_profiles = '65568',
  $manager_class     = 'neutron.plugins.cisco.segmentation.l2network_vlan_mgr_v2.L2NetworkVLANMgr',
  $max_networks      = '65568',
  $package_ensure    = 'present',
  $purge_config      = false,
)
{
  include ::neutron::deps

  ensure_resource('file', '/etc/neutron/plugins', {
    ensure => directory,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640'}
  )

  ensure_resource('file', '/etc/neutron/plugins/cisco', {
    ensure => directory,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640'}
  )

  if $::operatingsystem == 'Ubuntu' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path  => '/etc/default/neutron-server',
      match => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line  => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::cisco_config_file}",
      tag   => 'neutron-file-line',
    }
  }

  package { 'neutron-plugin-cisco':
    ensure => $package_ensure,
    name   => $::neutron::params::cisco_server_package,
    tag    => ['neutron-support-package', 'openstack'],
  }

  # Setting purge for all configs
  resources { 'neutron_plugin_cisco':
    purge => $purge_config,
  }

  resources { 'neutron_plugin_cisco_db_conn':
    purge => $purge_config,
  }

  resources { 'neutron_plugin_cisco_l2network':
    purge => $purge_config,
  }

  resources { 'neutron_plugin_cisco_credentials':
    purge => $purge_config,
  }

  neutron_plugin_cisco {
    'PLUGINS/nexus_plugin' : value => $nexus_plugin;
  }

  if $vswitch_plugin {
    neutron_plugin_cisco {
      'PLUGINS/vswitch_plugin' : value => $vswitch_plugin;
    }
  }

  # neutron-server will crash if the inventory section is empty.
  # this is usually used for specifying which physical nexus
  # devices are to be used.
  neutron_plugin_cisco {
    'INVENTORY/dummy' : value => 'dummy';
  }

  neutron_plugin_cisco_db_conn {
    'DATABASE/name': value => $database_name;
    'DATABASE/user': value => $database_user;
    'DATABASE/pass': value => $database_pass;
    'DATABASE/host': value => $database_host;
  }

  neutron_plugin_cisco_l2network {
    'VLANS/vlan_start':               value => $vlan_start;
    'VLANS/vlan_end':                 value => $vlan_end;
    'VLANS/vlan_name_prefix':         value => $vlan_name_prefix;
    'MODEL/model_class':              value => $model_class;
    'PORTS/max_ports':                value => $max_ports;
    'PORTPROFILES/max_port_profiles': value => $max_port_profiles;
    'NETWORKS/max_networks':          value => $max_networks;
    'SEGMENTATION/manager_class':     value => $manager_class;
  }

  neutron_plugin_cisco_credentials {
    'keystone/username': value => $keystone_username;
    'keystone/password': value => $keystone_password, secret => true;
    'keystone/auth_url': value => $keystone_auth_url;
    'keystone/tenant'  : value => $keystone_tenant;
  }

  # In RH, this link is used to start Neutron process but in Debian, it's used only
  # to manage database synchronization.
  if defined(File['/etc/neutron/plugin.ini']) {
    File <| path == '/etc/neutron/plugin.ini' |> { target => '/etc/neutron/plugins/cisco/cisco_plugins.ini' }
  }
  else {
    file {'/etc/neutron/plugin.ini':
      ensure => link,
      target => '/etc/neutron/plugins/cisco/cisco_plugins.ini',
      tag    => 'neutron-config-file',
    }
  }
}
