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
# [*auth_strategy*]
#   (optional) Method to use for authentication: noauth or keystone.
#   Defaults to $::os_service_default
#
# [*ironic_url*]
#   (optional) Ironic API URL, used to set Ironic API URL when auth_strategy
#   option is noauth to work with standalone Ironic without keystone.
#   Defaults to $::os_service_default
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
#   Defaults to 'http://127.0.0.1:35357'
#
# [*username*]
#   (optional) Username for connection to ironic in admin context
#   Defaults to 'ironic'
#
# [*project_domain_id*]
#   (optional) Domain ID containing project
#   Defaults to 'default'
#
# [*project_domain_name*]
#   (Optional) Domain name containing project
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) Project name to scope to
#   Defaults to 'services'
#
# [*user_domain_id*]
#   (optional) User's domain ID for connection to ironic in admin context
#   Defaults to 'default'
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
# [*retry_interval*]
#   (optional) Interval between retries in case of conflict error (HTTP 409).
#   Defaults to $::os_service_default
#
# [*max_retries*]
#   (optional) Maximum number of retries in case of conflict error (HTTP 409).
#   Defaults to $::os_service_default
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options in the
#   ironic-neutron-agent config.
#   Defaults to false.
#
class neutron::agents::ml2::networking_baremetal (
  $password,
  $enabled             = true,
  $manage_service      = true,
  $package_ensure      = 'present',
  $auth_strategy       = $::os_service_default,
  $ironic_url          = $::os_service_default,
  $cafile              = $::os_service_default,
  $certfile            = $::os_service_default,
  $keyfile             = $::os_service_default,
  $insecure            = $::os_service_default,
  $auth_type           = 'password',
  $auth_url            = 'http://127.0.0.1:35357',
  $username            = 'ironic',
  $project_domain_id   = 'default',
  $project_domain_name = 'Default',
  $project_name        = 'services',
  $user_domain_id      = 'default',
  $user_domain_name    = 'Default',
  $region_name         = $::os_service_default,
  $retry_interval      = $::os_service_default,
  $max_retries         = $::os_service_default,
  $purge_config        = false,
) {

  include ::neutron::deps
  include ::neutron::params

  if($::osfamily != 'RedHat') {
    # Drivers are only packaged for RedHat at this time
    fail("Unsupported osfamily ${::osfamily}")
  }

  resources { 'ironic_neutron_agent_config':
    purge => $purge_config,
  }

  ironic_neutron_agent_config {
    'ironic/auth_strategy':       value => $auth_strategy;
    'ironic/ironic_url':          value => $ironic_url;
    'ironic/cafile':              value => $cafile;
    'ironic/certfile':            value => $certfile;
    'ironic/keyfile':             value => $keyfile;
    'ironic/insecure':            value => $insecure;
    'ironic/auth_type':           value => $auth_type;
    'ironic/auth_url':            value => $auth_url;
    'ironic/username':            value => $username;
    'ironic/password':            value => $password;
    'ironic/project_domain_id':   value => $project_domain_id;
    'ironic/project_domain_name': value => $project_domain_name;
    'ironic/project_name':        value => $project_name;
    'ironic/user_domain_id':      value => $user_domain_id;
    'ironic/user_domain_name':    value => $user_domain_name;
    'ironic/region_name':         value => $region_name;
    'ironic/retry_interval':      value => $retry_interval;
    'ironic/max_retries':         value => $max_retries;
  }

  package { 'python2-ironic-neutron-agent':
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
