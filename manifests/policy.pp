# == Class: neutron::policy
#
# Configure the neutron policies
#
# === Parameters
#
# [*enforce_scope*]
#  (Optional) Whether or not to enforce scope when evaluating policies.
#  Defaults to $facts['os_service_default'].
#
# [*enforce_new_defaults*]
#  (Optional) Whether or not to use old deprecated defaults when evaluating
#  policies.
#  Defaults to $facts['os_service_default'].
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
# [*policy_default_rule*]
#   (Optional) Default rule. Enforced when a requested rule is not found.
#   Defaults to $facts['os_service_default'].
#
# [*policy_dirs*]
#   (Optional) Path to the neutron policy folder
#   Defaults to $facts['os_service_default']
#
# [*purge_config*]
#   (optional) Whether to set only the specified policy rules in the policy
#    file.
#    Defaults to false.
#
class neutron::policy (
  $enforce_scope                    = $facts['os_service_default'],
  $enforce_new_defaults             = $facts['os_service_default'],
  Openstacklib::Policies $policies  = {},
  Stdlib::Absolutepath $policy_path = '/etc/neutron/policy.yaml',
  $policy_default_rule              = $facts['os_service_default'],
  $policy_dirs                      = $facts['os_service_default'],
  Boolean $purge_config             = false,
) {
  include neutron::deps
  include neutron::params

  $policy_parameters = {
    policies     => $policies,
    policy_path  => $policy_path,
    file_user    => 'root',
    file_group   => $neutron::params::group,
    file_format  => 'yaml',
    purge_config => $purge_config,
  }

  create_resources('openstacklib::policy', { $policy_path => $policy_parameters })

  # policy config should occur in the config block also.
  Anchor['neutron::config::begin']
  -> Openstacklib::Policy[$policy_path]
  -> Anchor['neutron::config::end']

  oslo::policy { 'neutron_config':
    enforce_scope        => $enforce_scope,
    enforce_new_defaults => $enforce_new_defaults,
    policy_file          => $policy_path,
    policy_default_rule  => $policy_default_rule,
    policy_dirs          => $policy_dirs,
  }
}
