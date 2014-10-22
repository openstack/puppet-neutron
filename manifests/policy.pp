# == Class: neutron::policy
#
# Configure the neutron policies
#
# === Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for neutron
#   Example : { 'neutron-context_is_admin' => {'context_is_admin' => 'true'}, 'neutron-default' => {'default' => 'rule:admin_or_owner'} }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (optional) Path to the neutron policy.json file
#   Defaults to /etc/neutron/policy.json
#
class neutron::policy (
  $policies    = {},
  $policy_path = '/etc/neutron/policy.json',
) {

  Openstacklib::Policy::Base {
    file_path => $policy_path,
  }
  class { 'openstacklib::policy' :
    policies => $policies,
  }

}
