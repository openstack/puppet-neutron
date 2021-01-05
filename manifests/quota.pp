# == Class: neutron::quota
#
# Setups neutron quota.
#
# === Parameters
#
# [*default_quota*]
#   (optional) Default number of resources allowed per tenant,
#   minus for unlimited. Defaults to $::os_service_default.
#
# [*quota_network*]
#   (optional) Number of networks allowed per tenant, and minus means unlimited.
#   Defaults to $::os_service_default.
#
# [*quota_subnet*]
#   (optional) Number of subnets allowed per tenant, and minus means unlimited.
#   Defaults to $::os_service_default.
#
# [*quota_port*]
#   (optional) Number of ports allowed per tenant, and minus means unlimited.
#   Defaults to $::os_service_default.
#
# [*quota_router*]
#   (optional) Number of routers allowed per tenant, and minus means unlimited.
#   Requires L3 extension. Defaults to $::os_service_default.
#
# [*quota_floatingip*]
#   (optional) Number of floating IPs allowed per tenant,
#   and minus means unlimited. Requires L3 extension. Defaults to $::os_service_default.
#
# [*quota_security_group*]
#   (optional) Number of security groups allowed per tenant,
#   and minus means unlimited. Requires securitygroup extension.
#   Defaults to $::os_service_default.
#
# [*quota_security_group_rule*]
#   (optional) Number of security rules allowed per tenant,
#   and minus means unlimited. Requires securitygroup extension.
#   Defaults to $::os_service_default.
#
# [*quota_driver*]
#   (optional) Default driver to use for quota checks.
#   Defaults to $::os_service_default.
#
# [*quota_firewall*]
#   (optional) Number of firewalls allowed per tenant, -1 for unlimited.
#   Defaults to $::os_service_default.
#
# [*quota_firewall_policy*]
#   (optional) Number of firewalls policies allowed per tenant, -1 for unlimited.
#   Defaults to $::os_service_default.
#
# [*quota_firewall_rule*]
#   (optional) Number of firewalls rules allowed per tenant, -1 for unlimited.
#   Defaults to '-1'.
#
# [*quota_network_gateway*]
#   (optional) Number of network gateways allowed per tenant, -1 for unlimited.
#   Defaults to '5'.
#
# [*quota_packet_filter*]
#   (optional) Number of packet_filters allowed per tenant, -1 for unlimited.
#   Defaults to '100'.
#
# [*quota_vip*]
#   (optional) Number of vips allowed per tenant.
#   A negative value means unlimited.
#   Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
# [*quota_loadbalancer*]
#   (optional) Number of loadbalancers allowed per tenant.
#   A negative value means unlimited.
#   Defaults to undef.
#
# [*quota_pool*]
#   (optional) Number of pools allowed per tenant.
#   A negative value means unlimited.
#   Defaults to undef.
#
# [*quota_member*]
#   (optional) Number of pool members allowed per tenant.
#   A negative value means unlimited
#   Defaults to undef.
#
# [*quota_healthmonitor*]
#   (optional) Number of health monitors allowed per tenant.
#   A negative value means unlimited.
#   Defaults to undef.
#
class neutron::quota (
  $default_quota             = $::os_service_default,
  $quota_network             = $::os_service_default,
  $quota_subnet              = $::os_service_default,
  $quota_port                = $::os_service_default,
  # l3 extension
  $quota_router              = $::os_service_default,
  $quota_floatingip          = $::os_service_default,
  # securitygroup extension
  $quota_security_group      = $::os_service_default,
  $quota_security_group_rule = $::os_service_default,
  $quota_driver              = $::os_service_default,
  $quota_firewall            = $::os_service_default,
  $quota_firewall_policy     = $::os_service_default,
  $quota_firewall_rule       = -1,
  $quota_network_gateway     = 5,
  $quota_packet_filter       = 100,
  $quota_vip                 = $::os_service_default,
  # DEPRECATED PARAMETERS
  $quota_loadbalancer        = undef,
  $quota_pool                = undef,
  $quota_member              = undef,
  $quota_healthmonitor       = undef,
) {

  include neutron::deps

  $deprecated_param_names = [
    'quota_loadbalancer', 'quota_pool', 'quota_member', 'quota_healthmonitor'
  ]
  $deprecated_param_names.each |$param_name| {
    $param = getvar($param_name)
    if $param != undef {
      warning("The ${param_name} parameter has been deprecated and has no effect")
    }
  }

  neutron_config {
    'quotas/default_quota':             value => $default_quota;
    'quotas/quota_network':             value => $quota_network;
    'quotas/quota_subnet':              value => $quota_subnet;
    'quotas/quota_port':                value => $quota_port;
    'quotas/quota_router':              value => $quota_router;
    'quotas/quota_floatingip':          value => $quota_floatingip;
    'quotas/quota_security_group':      value => $quota_security_group;
    'quotas/quota_security_group_rule': value => $quota_security_group_rule;
    'quotas/quota_driver':              value => $quota_driver;
    'quotas/quota_firewall':            value => $quota_firewall;
    'quotas/quota_firewall_policy':     value => $quota_firewall_policy;
    'quotas/quota_firewall_rule':       value => $quota_firewall_rule;
    'quotas/quota_network_gateway':     value => $quota_network_gateway;
    'quotas/quota_packet_filter':       value => $quota_packet_filter;
    'quotas/quota_vip':                 value => $quota_vip;
  }
}
