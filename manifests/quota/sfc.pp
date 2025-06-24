# == Class: neutron::quota::sfc
#
# Setups neutron quota for networking-sfc.
#
# === Parameters
#
# [*quota_port_chain*]
#  (Optional) Maximum number of port chain per tenant.
#  Defaults to $facts['os_service_default'].
#
# [*quota_port_pair_group*]
#  (Optional) Maximum number of port pair group per tenant.
#  Defaults to $facts['os_service_default'].
#
# [*quota_port_pair*]
#  (Optional) Maximum number of port pair per tenant.
#  Defaults to $facts['os_service_default'].
#
# [*quota_service_graphs*]
#  (Optional) Maximum number of Service Graphs per tenant.
#  Defaults to $facts['os_service_default'].
#
# [*quota_flow_classifier*]
#  (Optional) Maximum number of Flow Classifiers per tenant.
#  Defaults to $facts['os_service_default'].
#
class neutron::quota::sfc (
  $quota_port_chain      = $facts['os_service_default'],
  $quota_port_pair_group = $facts['os_service_default'],
  $quota_port_pair       = $facts['os_service_default'],
  $quota_service_graphs  = $facts['os_service_default'],
  $quota_flow_classifier = $facts['os_service_default']
) {

  include neutron::deps

  neutron_config {
    'quotas/quota_port_chain':      value => $quota_port_chain;
    'quotas/quota_port_pair_group': value => $quota_port_pair_group;
    'quotas/quota_port_pair':       value => $quota_port_pair;
    'quotas/quota_service_graphs':  value => $quota_service_graphs;
    'quotas/quota_flow_classifier': value => $quota_flow_classifier;
  }
}
