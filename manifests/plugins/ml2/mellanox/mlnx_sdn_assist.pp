#
# Install the OpenDaylight and generate config file
# from parameters in the other classes.
#
# === Parameters
#
# [*sdn_username*]
# (optional) The Mellanox controller username
# Defaults to $::os_service_default
# Example: 'admin'
#
# [*sdn_password*]
# (optional) The Mellanox controller password
# Defaults to $::os_service_default
# Example: 'admin'
#
# [*sdn_url*]
# (optional) The Mellanox controller neutron URL
# Defaults to $::os_service_default
# Example: 'http://127.0.0.1/neo'
#
# [*sdn_domain*]
# (optional) The Mellanox controller domain
# Defaults to $::os_service_default
# Example: 'cloudx'
#
class neutron::plugins::ml2::mellanox::mlnx_sdn_assist (
  $sdn_username = $::os_service_default,
  $sdn_password = $::os_service_default,
  $sdn_url      = $::os_service_default,
  $sdn_domain   = $::os_service_default,
) {

  include ::neutron::deps
  require ::neutron::plugins::ml2

  neutron_plugin_ml2 {
    'sdn/username': value => $sdn_username;
    'sdn/password': value => $sdn_password, secret => true;
    'sdn/url':      value => $sdn_url;
    'sdn/domain':   value => $sdn_domain;
  }
}
