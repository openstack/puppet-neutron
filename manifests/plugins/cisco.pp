#
# DEPRECATED !
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
# Defaults to http://127.0.0.1:5000/v3/
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
  $keystone_auth_url = 'http://127.0.0.1:5000/v3/',

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
) {

  warning('Support for the Neutron Cisco plugin was deprecated and has no effect')
}
