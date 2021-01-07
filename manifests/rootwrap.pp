# == Class: neutron::rootwrap
#
# Manages the neutron rootwrap.conf file on systems
#
# === Parameters:
#
# DEPRECATED PARAMETERS
#
# [*xenapi_connection_url*]
#   (optional) XenAPI connection URL. Only needed when target a XenServer/XCP
#   compute host's dom0
#   Defaults to undef.
#
# [*xenapi_connection_username*]
#   (optional) XenAPI username. Only needed when target a XenServer/XCP
#   compute host's dom0
#   Defaults to undef.
#
# [*xenapi_connection_password*]
#   (optional) XenAPI connection password. Only needed when target a XenServer/XCP
#   compute host's dom0
#   Defaults to undef.
#
class neutron::rootwrap (
  # DEPRECATED PARAMETERS
  $xenapi_connection_url      = undef,
  $xenapi_connection_username = undef,
  $xenapi_connection_password = undef,
) {

  include neutron::deps

  $deprecated_xenapi_param_names = [
    'xenapi_connection_url',
    'xenapi_connection_username',
    'xenapi_connection_password',
  ]
  $deprecated_xenapi_param_names.each |$param_name| {
    $param = getvar($param_name)
    if $param != undef {
      warning("The ${param_name} parameter is deprecated and has no effect.")
    }
  }

}
