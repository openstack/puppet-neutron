# Configure the neutron server to use the plumgrid plugin.
# === Parameters
#
class neutron::plugins::plumgrid (
  $package_ensure       = 'installed',
  $connection           = undef,
  $pg_director_server   = undef,
  $pg_director_server_port = undef,
  $pg_username          = undef,
  $pg_password          = undef,
  $pg_servertimeout     = undef,

) {

  include neutron::params

  Package['neutron'] -> Package['neutron-plugin-plumgrid']
  Package['neutron-plugin-plumgrid'] -> Neutron_plugin_plumgrid<||>
  Neutron_plugin_plumgrid<||> ~> Service<| title == 'neutron-server' |>
  Package['neutron-plugin-plumgrid'] -> Service<| title == 'neutron-server' |>

  package { 'neutron-plugin-plumgrid':
    ensure  => $package_ensure,
    name    => $::neutron::params::plumgrid_plugin_package,
  }

  neutron_plugin_plumgrid {
    'PLUMGRID/connection': value => $connection;
    'PLUMGRID/director_server': value => $pg_director_server;
    'PLUMGRID/director_server_port' : value => $pg_director_server_port;
    'PLUMGRID/username': value => $pg_username;
    'PLUMGRID/password': value => $pg_password;
    'PLUMGRID/servertimeout': value => $pg_servertimeout;
  }

}
