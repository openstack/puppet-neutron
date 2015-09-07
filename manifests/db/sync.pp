#
# Class to execute neutron dbsync
#
class neutron::db::sync {

  include ::neutron::params

  Package<| tag == 'neutron-package' |> ~> Exec['neutron-db-sync']
  Exec['neutron-db-sync'] ~> Service <| tag == 'neutron-service' |>

  Neutron_config<||> ~> Exec['neutron-db-sync']
  Neutron_config<| title == 'database/connection' |> ~> Exec['neutron-db-sync']

  exec { 'neutron-db-sync':
    command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
    path        => '/usr/bin',
    refreshonly => true,
    logoutput   => on_failure,
  }
}
