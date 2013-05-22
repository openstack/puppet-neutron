# == Class: quantum::plugins::linuxbridge
#
# Setups linuxbridge plugin for quantum server.
#
# === Parameters
#
# [*sql_connection*]
#   (required) SQL connection string with the format:
#   [driver]://[user]:[password]@[host]/[database]
#
# [*network_vlan_ranges*]
#   (required) Comma-separated list of <physical_network>[:<vlan_min>:<vlan_max>]
#   tuples enumerating ranges of VLAN IDs on named physical networks that are
#   available for allocation.
#
# [*tenant_network_type*]
#   (optional) Type of network to allocate for tenant networks.
#   Defaults to 'vlan'.
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
class quantum::plugins::linuxbridge (
  $sql_connection,
  $network_vlan_ranges,
  $tenant_network_type = 'vlan',
  $package_ensure      = 'present'
) {

  include quantum::params

  Package['quantum'] -> Package['quantum-plugin-linuxbridge']
  Package['quantum-plugin-linuxbridge'] -> Quantum_plugin_linuxbridge<||>
  Quantum_plugin_linuxbridge<||> ~> Service<| title == 'quantum-server' |>
  Package['quantum-plugin-linuxbridge'] -> Service<| title == 'quantum-server' |>

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/quantum-server:QUANTUM_PLUGIN_CONFIG':
      path    => '/etc/default/quantum-server',
      match   => '^QUANTUM_PLUGIN_CONFIG=(.*)$',
      line    => "QUANTUM_PLUGIN_CONFIG=${::quantum::params::linuxbridge_config_file}",
      require => Package['quantum-plugin-linuxbridge'],
      notify  => Service['quantum-server'],
    }
  }

  package { 'quantum-plugin-linuxbridge':
    ensure => $package_ensure,
    name   => $::quantum::params::linuxbridge_server_package,
  }

  quantum_plugin_linuxbridge {
    'DATABASE/sql_connection':   value => $sql_connection;
    'VLANS/tenant_network_type': value => $tenant_network_type;
    'VLANS/network_vlan_ranges': value => $network_vlan_ranges;
  }
}
