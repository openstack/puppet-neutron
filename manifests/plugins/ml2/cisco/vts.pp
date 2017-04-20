# == Define: neutron::plugins::ml2::cisco::vts
#
# Install the Cisco VTS driver and generate the ML2 config file
# from parameters in the other classes.
#
# === Parameters
#
# [*package_ensure*]
# (optional) The intended state of the cisco-vts-ml2-driver
# package, i.e. any of the possible values of the 'ensure'
# property for a package resource type.
# Defaults to 'present'
#
# [*vts_username*]
# (optional) The VTS controller username
# Defaults to $::os_service_default
# Example: 'admin'
#
# [*vts_password*]
# (optional) The VTS controller password
# Defaults to $::os_service_default
# Example: 'admin'
#
# [*vts_url*]
# (optional) The VTS controller neutron URL
# Defaults to $::os_service_default
# Example: 'http://127.0.0.1:8888/api/running/openstack'
#
# [*vts_timeout*]
# (optional) Timeout for connection to vts host REST interface.
# Defaults to $::os_service_default
#
# [*vts_sync_timeout*]
# (optional) Timeout for synchronization to VTS.
# Defaults to $::os_service_default
#
# [*vts_retry_count*]
# (optional) Numer of retries for synchronization with VTS.
# Defaults to $::os_service_default
#
class neutron::plugins::ml2::cisco::vts (
  $vts_username,
  $vts_password,
  $vts_url,
  $vts_timeout             = $::os_service_default,
  $vts_sync_timeout        = $::os_service_default,
  $vts_retry_count         = $::os_service_default,
) {

  include ::neutron::deps
  require ::neutron::plugins::ml2

  neutron_plugin_ml2 {
    'ml2_cc/username':                value => $vts_username;
    'ml2_cc/password':                value => $vts_password, secret => true;
    'ml2_cc/url':                     value => $vts_url;
    'ml2_cc/timeout':                 value => $vts_timeout;
    'ml2_cc/sync_timeout':            value => $vts_sync_timeout;
    'ml2_cc/retry_count':             value => $vts_retry_count;
  }
}
