# == Class: neutron::rootwrap
#
# Manages the neutron rootwrap.conf file on systems
#
# === Parameters:
#
# [*xenapi_connection_url*]
#   (optional) XenAPI connection URL. Only needed when target a XenServer/XCP
#   compute host's dom0
#   Defaults to $::os_service_default.
#
# [*xenapi_connection_username*]
#   (optional) XenAPI username. Only needed when target a XenServer/XCP
#   compute host's dom0
#   Defaults to $::os_service_default.
#
# [*xenapi_connection_password*]
#   (optional) XenAPI connection password. Only needed when target a XenServer/XCP
#   compute host's dom0
#   Defaults to $::os_service_default.
#
class neutron::rootwrap (
  $xenapi_connection_url      = $::os_service_default,
  $xenapi_connection_username = $::os_service_default,
  $xenapi_connection_password = $::os_service_default,
) {

  include ::neutron::deps

  neutron_rootwrap_config {
    'xenapi/xenapi_connection_url':      value => $xenapi_connection_url;
    'xenapi/xenapi_connection_username': value => $xenapi_connection_username;
    'xenapi/xenapi_connection_password': value => $xenapi_connection_password;
  }

}
