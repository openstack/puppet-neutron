
#
# Configure the cisco quantum plugin
# More info available here:
# https://wiki.openstack.org/wiki/Cisco-quantum
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
# Defaults to quantum
#
# [*database_user*]
# The user that will be used to connect to the db
# Defaults to quantum
#
# [*database_host*]
# The address or hostname of the database
# Defaults to 127.0.0.1
#
# [*keystone_username*]
# The admin username for the plugin to use
# Defaults to quantum
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
# Defaults to ovs_quantum_plugin.OVSQuantumPluginV2
#
# [*nexus_plugin*]
# (optional) The nexus plugin to use
# Defaults to undef. This will not set a nexus plugin to use
# Can be set to quantum.plugins.cisco.nexus.cisco_nexus_plugin_v2.NexusPlugin
#
# Other parameters are currently not used by the plugin and
# can be left unchanged, but in grizzly the plugin will fail
# to launch if they are not there. The config for Havana will
# move to a single config file and this will be simplified.

class quantum::plugins::cisco(
  $keystone_password,
  $database_pass,

  # Database connection
  $database_name     = 'quantum',
  $database_user     = 'quantum',
  $database_host     = '127.0.0.1',

  # Keystone connection
  $keystone_username = 'quantum',
  $keystone_tenant   = 'services',
  $keystone_auth_url = 'http://127.0.0.1:35357/v2.0/',

  $vswitch_plugin = 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
  $nexus_plugin   = undef,

  # Plugin minimum configuration
  $vlan_start        = '100',
  $vlan_end          = '3000',
  $vlan_name_prefix  = 'q-',
  $model_class       = 'quantum.plugins.cisco.models.virt_phy_sw_v2.VirtualPhysicalSwitchModelV2',
  $max_ports         = '100',
  $max_port_profiles = '65568',
  $manager_class     = 'quantum.plugins.cisco.segmentation.l2network_vlan_mgr_v2.L2NetworkVLANMgr',
  $max_networks      = '65568',
  $package_ensure    = 'present'
)
{

  include quantum::params

  Quantum_plugin_cisco<||> ~> Service['quantum-server']
  Quantum_plugin_cisco_db_conn<||> ~> Service['quantum-server']
  Quantum_plugin_cisco_l2network<||> ~> Service['quantum-server']

  ensure_resource('file', '/etc/quantum/plugins', {
    ensure => directory,
    owner   => 'root',
    group   => 'quantum',
    mode    => '0640'}
  )

  ensure_resource('file', '/etc/quantum/plugins/cisco', {
    ensure => directory,
    owner   => 'root',
    group   => 'quantum',
    mode    => '0640'}
  )

  # Ensure the quantum package is installed before config is set
  # under both RHEL and Ubuntu
  if ($::quantum::params::server_package) {
    Package['quantum-server'] -> Quantum_plugin_cisco<||>
    Package['quantum-server'] -> Quantum_plugin_cisco_db_conn<||>
    Package['quantum-server'] -> Quantum_plugin_cisco_l2network<||>
  } else {
    Package['quantum'] -> Quantum_plugin_cisco<||>
    Package['quantum'] -> Quantum_plugin_cisco_db_conn<||>
    Package['quantum'] -> Quantum_plugin_cisco_l2network<||>
  }

  if $::osfamily == 'Debian' {
    # Only set the quantum_plugin_config path for n1k as it uses single config for grizzly.
    # rest of the plugins default to multi config.
    if $vswitch_plugin == 'quantum.plugins.cisco.n1kv.n1kv_quantum_plugin.N1kvQuantumPluginV2' {
      file_line { '/etc/default/quantum-server:QUANTUM_PLUGIN_CONFIG':
        path    => '/etc/default/quantum-server',
        match   => '^QUANTUM_PLUGIN_CONFIG=(.*)$',
        line    => "QUANTUM_PLUGIN_CONFIG=${::quantum::params::cisco_config_file}",
        require => [ Package['quantum-server'], Package['quantum-plugin-cisco'] ],
        notify  => Service['quantum-server'],
      }
    }
  }

  package { 'quantum-plugin-cisco':
    ensure => $package_ensure,
    name   => $::quantum::params::cisco_server_package,
  }


  if $nexus_plugin {
    quantum_plugin_cisco {
      'PLUGINS/nexus_plugin' : value => $nexus_plugin;
    }
  }

  if $vswitch_plugin {
    quantum_plugin_cisco {
      'PLUGINS/vswitch_plugin' : value => $vswitch_plugin;
    }
  }

  # quantum-server will crash if the inventory section is empty.
  # this is usually used for specifying which physical nexus
  # devices are to be used.
  quantum_plugin_cisco {
    'INVENTORY/dummy' : value => 'dummy';
  }

  quantum_plugin_cisco_db_conn {
    'DATABASE/name': value => $database_name;
    'DATABASE/user': value => $database_user;
    'DATABASE/pass': value => $database_pass;
    'DATABASE/host': value => $database_host;
  }

  quantum_plugin_cisco_l2network {
    'VLANS/vlan_start':               value => $vlan_start;
    'VLANS/vlan_end':                 value => $vlan_end;
    'VLANS/vlan_name_prefix':         value => $vlan_name_prefix;
    'MODEL/model_class':              value => $model_class;
    'PORTS/max_ports':                value => $max_ports;
    'PORTPROFILES/max_port_profiles': value => $max_port_profiles;
    'NETWORKS/max_networks':          value => $max_networks;
    'SEGMENTATION/manager_class':     value => $manager_class;
  }

  quantum_plugin_cisco_credentials {
    'keystone/username': value => $keystone_username;
    'keystone/password': value => $keystone_password;
    'keystone/auth_url': value => $keystone_auth_url;
    'keystone/tenant'  : value => $keystone_tenant;
  }
}
