# == Class: neutron::plugins::ml2::midonet
#
# Configure the Mech Driver for midonet neutron plugin
#
# === Parameters:
#
# [*midonet_uri*]
#   (required) MidoNet API server URI.
#   Usually of the form 'http://<midonet-api-hostname>:8080/midonet-api'
#
# [*username*]
#   (required) MidoNet admin username.
#
# [*password*]
#   (required) MidoNet admin password.
#
# [*project_id*]
#   (optional) Name of the project that MidoNet admin user belongs to.
#   Defaults to 'service'
#
class neutron::plugins::ml2::midonet (
  $midonet_uri,
  $username,
  $password,
  $project_id = 'services',
) {

  include ::neutron::deps

  neutron_plugin_ml2 {
    'MIDONET/midonet_uri' : value => $midonet_uri;
    'MIDONET/username'    : value => $username;
    'MIDONET/password'    : value => $password, secret => true;
    'MIDONET/project_id'  : value => $project_id;
  }

}
