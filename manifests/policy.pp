# == Class: neutron::policy
#
# Configure the neutron policies
#
# === Parameters
#
# [*policies*]
#   (Optional) Set of policies to configure for neutron
#   Example :
#     {
#       'neutron-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'neutron-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (Optional) Path to the neutron policy.yaml file
#   Defaults to /etc/neutron/policy.yaml
#
class neutron::policy (
  $policies    = {},
  $policy_path = '/etc/neutron/policy.yaml',
) {

  include neutron::deps
  include neutron::params

  validate_legacy(Hash, 'validate_hash', $policies)

  Openstacklib::Policy::Base {
    file_path   => $policy_path,
    file_user   => 'root',
    file_group  => $::neutron::params::group,
    file_format => 'yaml',
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'neutron_config': policy_file => $policy_path }

}
