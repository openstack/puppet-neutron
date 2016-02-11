#
# Class to execute neutron dbsync
#
class neutron::db::sync {

  include ::neutron::params

  Package<| title == 'neutron-server' |> -> Exec['neutron-db-sync']
  Package<| title == 'neutron' |> -> Exec['neutron-db-sync']
  Neutron_config<||> ~> Exec['neutron-db-sync']
  Neutron_config<| title == 'database/connection' |> ~> Exec['neutron-db-sync']
  Exec['neutron-db-sync'] ~> Service <| title == 'neutron-server' |>

  exec { 'neutron-db-sync':
    command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
    path        => '/usr/bin',
    refreshonly => true,
    logoutput   => on_failure,
  }
}
