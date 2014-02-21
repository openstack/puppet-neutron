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
  Package['neutron-plugin-plumgrid'] -> File['remove plumgrid.ini']
  File['remove plumgrid.ini'] -> Service<| title == 'neutron-server' |>
  Package['neutron-plugin-plumgrid'] -> Package['plumgrid-pythonlib']
  Package['plumgrid-pythonlib'] ~> Service<| title == 'neutron-server' |>

  file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path    => '/etc/default/neutron-server',
      match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line    => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::plumgrid_config_file}",
      require => [ Package['neutron-server'], Package['neutron-plugin-plumgrid'] ],
      notify  => Service['neutron-server'],
    }

  package { 'neutron-plugin-plumgrid':
    ensure  => $package_ensure,
    name    => $::neutron::params::plumgrid_plugin_package,
    configfiles => replace,
  }

  package { 'plumgrid-pythonlib':
    ensure  => $package_ensure,
    name    => $::neutron::params::plumgrid_pythonlib_package,
    configfiles => replace,
  }

  file { 'remove plumgrid.ini':
      path => '/etc/neutron/plugins/plumgrid/plumgrid.ini',
      ensure => absent,
      require => [Package['neutron-plugin-plumgrid'] ],
  }

  file { '/usr/share/pyshared/neutron/plugins/plumgrid/drivers/plumlib.py':
    ensure => file,
    content => template('neutron/plumlib.py.erb'),
    require => [Package['neutron-plugin-plumgrid'], Package['plumgrid-pythonlib'] ],
  }

  file { '/usr/share/pyshared/neutron/plugins/plumgrid/plumgrid_plugin/plumgrid_plugin.py':
    ensure => file,
    content => template('neutron/plumgrid_plugin.py.erb'),
    require => [Package['neutron-plugin-plumgrid'], Package['plumgrid-pythonlib'] ],
  }

  neutron_plugin_plumgrid {
    'PLUMgridDirector/director_server': value => $pg_director_server;
    'PLUMgridDirector/director_server_port' : value => $pg_director_server_port;
    'PLUMgridDirector/username': value => $pg_username;
    'PLUMgridDirector/password': value => $pg_password;
    'PLUMgridDirector/servertimeout': value => $pg_servertimeout;
    'database/connection': value => $connection;
  }

}
