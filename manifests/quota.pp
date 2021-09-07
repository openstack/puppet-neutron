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
# [*quota_network_gateway*]
#   (optional) Number of network gateways allowed per tenant, -1 for unlimited.
#   Defaults to '5'.
#
# [*quota_rbac_policy*]
#   (optional) Number of rbac policies allowed per tenant.
#   A negative value means unlimited.
#   Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
# [*quota_packet_filter*]
#   (optional) Number of packet_filters allowed per tenant, -1 for unlimited.
#   Defaults to undef.
#
# [*quota_vip*]
#   (optional) Number of vips allowed per tenant.
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
  $quota_network_gateway     = 5,
  # rbac extension
  $quota_rbac_policy         = $::os_service_default,
  # DEPRECATED PARAMETERS
  $quota_packet_filter       = undef,
  $quota_vip                 = undef,
) {

  include neutron::deps

  if $quota_packet_filter != undef {
    warning('The neutron::quota::quota_packet_filter parameter is deprecated and has no effect')
  }

  if $quota_vip != undef {
    warning('The neutron::quota::quota_vip parameter is deprecated and has no effect')
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
    'quotas/quota_network_gateway':     value => $quota_network_gateway;
    'quotas/quota_rbac_policy':         value => $quota_rbac_policy;
  }
}
