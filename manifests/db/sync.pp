#
# Class to execute neutron dbsync
#
# ==Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the neutron-db-manage upgrade heads command. These will be
#   inserted in the command line between 'neutron-db-manage' and
#   'upgrade heads'.
#   Defaults to ''
#
# [*db_sync_timeout*]
#   (optional) Timeout for the execution of the db_sync
#   Defaults to 300
#
#
class neutron::db::sync(
  $extra_params    = '',
  $db_sync_timeout = 300,
) {

  include ::neutron::deps
  include ::neutron::params

  exec { 'neutron-db-sync':
    command     => "neutron-db-manage ${extra_params} upgrade heads",
    path        => '/usr/bin',
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    timeout     => $db_sync_timeout,
    logoutput   => on_failure,
    subscribe   => [
      Anchor['neutron::install::end'],
      Anchor['neutron::config::end'],
      Anchor['neutron::dbsync::begin']
    ],
    notify      => Anchor['neutron::dbsync::end'],
    tag         => 'openstack-db',
  }
}
