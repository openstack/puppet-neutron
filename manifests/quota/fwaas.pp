# == Class: neutron::quota::fwaas
#
# Setups neutron quota for neutron-fwaas.
#
# === Parameters
#
# [*quota_firewall_group*]
#  (Optional) Number of firewall groups allowed per tenant.
#  Defaults to $facts['os_service_default'].
#
# [*quota_firewall_policy*]
#  (Optional) Number of firewall policies allowed per tenant.
#  Defaults to $facts['os_service_default'].
#
# [*quota_firewall_rule*]
#  (Optional) Number of firewall rules allowed per tenant.
#  Defaults to $facts['os_service_default'].
#
class neutron::quota::fwaas (
  $quota_firewall_group  = $facts['os_service_default'],
  $quota_firewall_policy = $facts['os_service_default'],
  $quota_firewall_rule   = $facts['os_service_default'],
) {
  include neutron::deps

  neutron_config {
    'quotas/quota_firewall_group':  value => $quota_firewall_group;
    'quotas/quota_firewall_policy': value => $quota_firewall_policy;
    'quotas/quota_firewall_rule':   value => $quota_firewall_rule;
  }
}
