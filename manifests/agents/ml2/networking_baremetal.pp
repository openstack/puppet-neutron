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
#   Defaults to $::os_service_default
#
# [*certfile*]
#   (optional) PEM encoded client certificate cert file
#   Defaults to $::os_service_default
#
# [*keyfile*]
#   (optional) PEM encoded client certificate key file
#   Defaults to $::os_service_default
#
# [*insecure*]
#   (optional) Verify HTTPS connections. (boolean)
#   Defaults to $::os_service_default
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
#   Defaults to $::os_service_default
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
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*region_name*]
#   (optional) Name of region to use. Useful if keystone manages more than one
#   region.
#   Defaults to $::os_service_default
#
# [*status_code_retry_delay*]
#   (optional) Interval between retries in case of conflict error (HTTP 409).
#   Defaults to $::os_service_default
#
# [*status_code_retries*]
#   (optional) Maximum number of retries in case of conflict error (HTTP 409).
#   Defaults to $::os_service_default
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options in the
#   ironic-neutron-agent config.
#   Defaults to false.
#
# DEPRECATED PARAMETERS
#
# [*auth_strategy*]
#   (optional) Method to use for authentication: noauth or keystone.
#   Defaults to undef
#
# [*ironic_url*]
#   (optional) Ironic API URL, used to set Ironic API URL when auth_strategy
#   option is noauth to work with standalone Ironic without keystone.
#   Defaults to undef
#
# [*retry_interval*]
#   (optional) Interval between retries in case of conflict error (HTTP 409).
#   Defaults to undef
#
# [*max_retries*]
#   (optional) Maximum number of retries in case of conflict error (HTTP 409).
#   Defaults to undef
#
class neutron::agents::ml2::networking_baremetal (
  $password,
  $enabled                 = true,
  $manage_service          = true,
  $package_ensure          = 'present',
  $endpoint_override       = $::os_service_default,
  $cafile                  = $::os_service_default,
  $certfile                = $::os_service_default,
  $keyfile                 = $::os_service_default,
  $insecure                = $::os_service_default,
  $auth_type               = 'password',
  $auth_url                = 'http://127.0.0.1:5000',
  $username                = 'ironic',
  $project_domain_name     = 'Default',
  $project_name            = 'services',
  $user_domain_name        = 'Default',
  $region_name             = $::os_service_default,
  $status_code_retry_delay = $::os_service_default,
  $status_code_retries     = $::os_service_default,
  $purge_config            = false,
  # DEPRECATED PARAMETERS
  $auth_strategy           = undef,
  $ironic_url              = undef,
  $retry_interval          = undef,
  $max_retries             = undef,
) {

  include neutron::deps
  include neutron::params

  if($::osfamily != 'RedHat') {
    # Drivers are only packaged for RedHat at this time
    fail("Unsupported osfamily ${::osfamily}")
  }

  resources { 'ironic_neutron_agent_config':
    purge => $purge_config,
  }

  if $auth_strategy != undef {
    warn('neutron::agents::ml2::networking_baremetal::auth_strategy is now deprecated \
and has no effect.')
  }

  if $ironic_url != undef {
    warn('neutron::agents::ml2::networking_baremetal::ironic_url is now deprecated. \
Use endpoint_override instead.')
  }

  if $retry_interval != undef {
    warn('neutron::agents::ml2::networking_baremetal::retry_interval is now deprecated. \
Use status_code_retry_delay instead.')
  }

  if $max_retries != undef {
    warn('neutron::agents::ml2::networking_baremetal::max_retries is now deprecated. \
Use status_code_retries instead.')
  }

  ironic_neutron_agent_config {
    'ironic/auth_strategy':  ensure => absent;
    'ironic/ironic_url':     ensure => absent;
    'ironic/retry_interval': ensure => absent;
    'ironic/max_retries':    ensure => absent;
  }

  $endpoint_override_real = pick($ironic_url, $endpoint_override)
  $status_code_retry_delay_real = pick($retry_interval, $status_code_retry_delay)
  $status_code_retries_real = pick($max_retries, $status_code_retries)

  ironic_neutron_agent_config {
    'ironic/endpoint_override':       value => $endpoint_override_real;
    'ironic/cafile':                  value => $cafile;
    'ironic/certfile':                value => $certfile;
    'ironic/keyfile':                 value => $keyfile;
    'ironic/insecure':                value => $insecure;
    'ironic/auth_type':               value => $auth_type;
    'ironic/auth_url':                value => $auth_url;
    'ironic/username':                value => $username;
    'ironic/password':                value => $password, secret => true;
    'ironic/project_domain_name':     value => $project_domain_name;
    'ironic/project_name':            value => $project_name;
    'ironic/user_domain_name':        value => $user_domain_name;
    'ironic/region_name':             value => $region_name;
    'ironic/status_code_retry_delay': value => $status_code_retry_delay_real;
    'ironic/status_code_retries':     value => $status_code_retries_real;
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
