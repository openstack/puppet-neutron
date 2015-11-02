#
# Class to execute neutron dbsync
#
# ==Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the neutron-db-manage upgrade head command. These will be
#   inserted in the command line between 'neutron-db-manage' and
#   'upgrade head'.
#   Defaults to '--config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini'
#
class neutron::db::sync(
  $extra_params = '--config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini',
) {

  include ::neutron::params

  Package<| tag == 'neutron-package' |> ~> Exec['neutron-db-sync']
  Exec['neutron-db-sync'] ~> Service <| tag == 'neutron-db-sync-service' |>

  Neutron_config<||> ~> Exec['neutron-db-sync']
  Neutron_config<| title == 'database/connection' |> ~> Exec['neutron-db-sync']

  exec { 'neutron-db-sync':
    command     => "neutron-db-manage ${extra_params} upgrade head",
    path        => '/usr/bin',
    refreshonly => true,
    logoutput   => on_failure,
  }
}
