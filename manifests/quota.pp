# == Class: neutron::quota
#
# Setups neutron quota.
#
# === Parameters
#
# [*default_quota*]
#   (optional) Default number of resources allowed per tenant,
#   minus for unlimited. Defaults to $facts['os_service_default'].
#
# [*quota_network*]
#   (optional) Number of networks allowed per tenant, and minus means unlimited.
#   Defaults to $facts['os_service_default'].
#
# [*quota_subnet*]
#   (optional) Number of subnets allowed per tenant, and minus means unlimited.
#   Defaults to $facts['os_service_default'].
#
# [*quota_port*]
#   (optional) Number of ports allowed per tenant, and minus means unlimited.
#   Defaults to $facts['os_service_default'].
#
# [*quota_router*]
#   (optional) Number of routers allowed per tenant, and minus means unlimited.
#   Requires L3 extension. Defaults to $facts['os_service_default'].
#
# [*quota_floatingip*]
#   (optional) Number of floating IPs allowed per tenant,
#   and minus means unlimited. Requires L3 extension. Defaults to $facts['os_service_default'].
#
# [*quota_security_group*]
#   (optional) Number of security groups allowed per tenant,
#   and minus means unlimited. Requires securitygroup extension.
#   Defaults to $facts['os_service_default'].
#
# [*quota_security_group_rule*]
#   (optional) Number of security rules allowed per tenant,
#   and minus means unlimited. Requires securitygroup extension.
#   Defaults to $facts['os_service_default'].
#
# [*quota_driver*]
#   (optional) Default driver to use for quota checks.
#   Defaults to $facts['os_service_default'].
#
# [*quota_rbac_policy*]
#   (optional) Number of rbac policies allowed per tenant.
#   A negative value means unlimited.
#   Defaults to $facts['os_service_default'].
#
class neutron::quota (
  $default_quota             = $facts['os_service_default'],
  $quota_network             = $facts['os_service_default'],
  $quota_subnet              = $facts['os_service_default'],
  $quota_port                = $facts['os_service_default'],
  # l3 extension
  $quota_router              = $facts['os_service_default'],
  $quota_floatingip          = $facts['os_service_default'],
  # securitygroup extension
  $quota_security_group      = $facts['os_service_default'],
  $quota_security_group_rule = $facts['os_service_default'],
  $quota_driver              = $facts['os_service_default'],
  # rbac extension
  $quota_rbac_policy         = $facts['os_service_default'],
) {

  include neutron::deps

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
    'quotas/quota_rbac_policy':         value => $quota_rbac_policy;
  }
}
