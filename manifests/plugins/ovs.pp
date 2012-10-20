class quantum::plugins::ovs (
  $package_ensure       = true,

  $sql_connection       = 'sqlite:////var/lib/quantum/ovs.sqlite',
  $sql_max_retries      = 10,
  $reconnect_interval   = 2,

  $bridge_mappings      = ['default:br-virtual'],
  $tenant_network_type  = 'vlan',
  $network_vlan_ranges  = 'default:1000:2000',
  $integration_bridge   = 'br-int',
  $enable_tunneling     = true,
  $tunnel_bridge        = 'br-tun',
  $tunnel_id_ranges     = '1:1000',
  $local_ip             = '10.0.0.1',

  $polling_interval     = 2,
  $root_helper          = 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf'
) {
  include 'quantum::params'

  require 'vswitch::ovs'

  Package['quantum'] -> Package['quantum-plugin-ovs']
  Package['quantum-plugin-ovs'] -> Quantum_plugin_ovs<||>
  Quantum_plugin_ovs<||> ~> Service<| title == 'quantum-server' |>
  Package['quantum-plugin-ovs'] -> Service<| title == 'quantum-server' |>

  validate_re($sql_connection, '(sqlite|mysql|posgres):\/\/(\S+:\S+@\S+\/\S+)?')

  if ($sql_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    ensure_resource( 'package', 'python-mysqldb', {'ensure' => 'present'})
  } elsif ($sql_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {
    ensure_resource( 'package', 'python-psycopg2', {'ensure' => 'present'})
  } elsif($sql_connection =~ /sqlite:\/\//) {
    ensure_resource( 'package', 'python-pysqlite2', {'ensure' => 'present'})
  } else {
    fail('Invalid db connection ${sql_connection}')
  }

  package { 'quantum-plugin-ovs':
    name    => $::quantum::params::ovs_server_package,
    ensure  => $package_ensure,
  }

  $br_map_str = join($bridge_mappings, ',')

  quantum_plugin_ovs {
    'DATABASE/sql_connection':    value => $sql_connection;
    'DATABASE/sql_max_retries':   value => $sql_max_retries;
    'DATABASE/sql_connection':    value => $sql_connection;
    'OVS/integration_bridge':     value => $integration_bridge;
    'OVS/network_vlan_ranges':    value => $network_vlan_ranges;
    'OVS/tenant_network_type':    value => $tenant_network_type;
    'OVS/bridge_mappings':        value => $br_map_str;
    'AGENT/polling_interval':     value => $polling_interval;
    'AGENT/root_helper':          value => $root_helper;
  }

  if ($tenant_network_type == 'gre') and ($enable_tunneling) {
    quantum_plugin_ovs {
      'OVS/enable_tunneling':   value => 'True';
      'OVS/tunnel_bridge':      value => $tunnel_bridge;
      'OVS/tunnel_id_ranges':   value => $tunnel_id_ranges;
      'OVS/local_ip':           value => $local_ip;
    }
  }
}
