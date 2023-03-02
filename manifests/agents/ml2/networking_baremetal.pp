# == Class: neutron::agents::ml2::networking_baremetal
#
# Setups networking-baremetal Neutron agent for ML2 plugin.
#
# === Parameters
#
# [*enabled*]
#   (required) Whether or not to enable the agent.
#   Defaults to true.
#
# [*password*]
#   (required) Password for connection to ironic in admin context.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*package_ensure*]
#   (optional) Package ensure state.
#   Defaults to 'present'.
#
# [*cafile*]
#   (optional) PEM encoded Certificate Authority to use when verifying HTTPs
#   connections.
#   Defaults to $facts['os_service_default']
#
# [*certfile*]
#   (optional) PEM encoded client certificate cert file
#   Defaults to $facts['os_service_default']
#
# [*keyfile*]
#   (optional) PEM encoded client certificate key file
#   Defaults to $facts['os_service_default']
#
# [*insecure*]
#   (optional) Verify HTTPS connections. (boolean)
#   Defaults to $facts['os_service_default']
#
# [*auth_type*]
#   (optional) An authentication type to use with an OpenStack Identity server.
#   The value should contain auth plugin name
#   Defaults to 'password'
#
# [*auth_url*]
#   (optional) Authorization URL for connection to ironic in admin context.
#   If version independent identity plugin is used available versions will be
#   determined using auth_url
#   Defaults to 'http://127.0.0.1:5000'
#
# [*endpoint_override*]
#   (optional) The ironic endpoint URL for requests
#   Defaults to $facts['os_service_default']
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*username*]
#   (optional) Username for connection to ironic in admin context
#   Defaults to 'ironic'
#
# [*project_domain_name*]
#   (Optional) Domain name containing project
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) Project name to scope to
#   Defaults to 'services'
#
# [*system_scope*]
#   (Optional) Scope for system operations
#   Defaults to $facts['os_service_default']
#
# [*region_name*]
#   (optional) Name of region to use. Useful if keystone manages more than one
#   region.
#   Defaults to $facts['os_service_default']
#
# [*status_code_retry_delay*]
#   (optional) Interval between retries in case of conflict error (HTTP 409).
#   Defaults to $facts['os_service_default']
#
# [*status_code_retries*]
#   (optional) Maximum number of retries in case of conflict error (HTTP 409).
#   Defaults to $facts['os_service_default']
#
# [*valid_interfaces*]
#   (Optional) List of interfaces, in order of preference for endpoint URL.
#   Defaults to $facts['os_service_default']
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options in the
#   ironic-neutron-agent config.
#   Defaults to false.
#
# [*report_interval*]
#   (optional) Set the agent report interval. By default the global report
#   interval in neutron.conf ([agent]/report_interval) is used. This parameter
#   can be used to override the reporting interval for the
#   ironic-neutron-agent.
#   Defaults to $facts['os_service_default']
#
class neutron::agents::ml2::networking_baremetal (
  $password,
  $enabled                 = true,
  $manage_service          = true,
  $package_ensure          = 'present',
  $endpoint_override       = $facts['os_service_default'],
  $cafile                  = $facts['os_service_default'],
  $certfile                = $facts['os_service_default'],
  $keyfile                 = $facts['os_service_default'],
  $insecure                = $facts['os_service_default'],
  $auth_type               = 'password',
  $auth_url                = 'http://127.0.0.1:5000',
  $user_domain_name        = 'Default',
  $username                = 'ironic',
  $project_domain_name     = 'Default',
  $project_name            = 'services',
  $system_scope            = $facts['os_service_default'],
  $region_name             = $facts['os_service_default'],
  $status_code_retry_delay = $facts['os_service_default'],
  $status_code_retries     = $facts['os_service_default'],
  $valid_interfaces        = $facts['os_service_default'],
  $purge_config            = false,
  $report_interval         = $facts['os_service_default'],
) {

  include neutron::deps
  include neutron::params

  resources { 'ironic_neutron_agent_config':
    purge => $purge_config,
  }

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $facts['os_service_default']
    $project_domain_name_real = $facts['os_service_default']
  }

  ironic_neutron_agent_config {
    'ironic/endpoint_override':       value => $endpoint_override;
    'ironic/cafile':                  value => $cafile;
    'ironic/certfile':                value => $certfile;
    'ironic/keyfile':                 value => $keyfile;
    'ironic/insecure':                value => $insecure;
    'ironic/auth_type':               value => $auth_type;
    'ironic/auth_url':                value => $auth_url;
    'ironic/user_domain_name':        value => $user_domain_name;
    'ironic/username':                value => $username;
    'ironic/password':                value => $password, secret => true;
    'ironic/project_domain_name':     value => $project_domain_name_real;
    'ironic/project_name':            value => $project_name_real;
    'ironic/system_scope':            value => $system_scope;
    'ironic/region_name':             value => $region_name;
    'ironic/status_code_retry_delay': value => $status_code_retry_delay;
    'ironic/status_code_retries':     value => $status_code_retries;
    'ironic/valid_interfaces':        value => join(any2array($valid_interfaces), ',');
    'agent/report_interval':          value => $report_interval;
  }

  package { 'python-ironic-neutron-agent':
    ensure => $package_ensure,
    name   => $::neutron::params::networking_baremetal_agent_package,
    tag    => ['openstack', 'neutron-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'ironic-neutron-agent-service':
      ensure => $service_ensure,
      name   => $::neutron::params::networking_baremetal_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
  }

}
