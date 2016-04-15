# == Class: neutron::agents::metadata
#
# Setup and configure Neutron metadata agent.
#
# === Parameters
#
# [*shared_secret*]
#   (required) Shared secret to validate proxies Neutron metadata requests.
#
# [*package_ensure*]
#   Ensure state of the package. Defaults to 'present'.
#
# [*enabled*]
#   State of the service. Defaults to true.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   Debug. Defaults to false.
#
# [*auth_ca_cert*]
#   CA cert to check against with for ssl keystone. (Defaults to $::os_service_default)
#
# [*nova_client_cert*]
#   Client certificate for nova metadata api server. (Defaults to $::os_service_default)
#
# [*nova_client_priv_key*]
#   Private key of client certificate. (Defaults to $::os_service_default)
#
# [*metadata_ip*]
#   The IP address of the metadata service. Defaults to $::os_service_default.
#
# [*metadata_port*]
#   The TCP port of the metadata service. Defaults to $::os_service_default.
#
# [*metadata_protocol*]
#   The protocol to use for requests to Nova metadata server. Defaults to $::os_service_default.
#
# [*metadata_workers*]
#   (optional) Number of separate worker processes to spawn.
#   The default, count of machine's processors, runs the worker thread in the
#   current process.
#   Greater than 0 launches that number of child processes as workers.
#   The parent process manages them. Having more workers will help to improve performances.
#   Defaults to: $::processorcount
#
# [*metadata_backlog*]
#   (optional) Number of backlog requests to configure the metadata server socket with.
#   Defaults to $::os_service_default
#
# [*metadata_memory_cache_ttl*]
#   (optional) Specifies time in seconds a metadata cache entry is valid in
#   memory caching backend.
#   Set to 0 will cause cache entries to never expire.
#   Set to $::os_service_default or false to disable cache.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the metadata config.
#   Defaults to false.
#
# === Deprecated Parameters
# [*auth_password*]
#   (required) The password for the administrative user (Defaults to undef).
#
# [*auth_tenant*]
#   The administrative user's tenant name (Defaults to undef).
#
# [*auth_user*]
#   The administrative user name for OpenStack Networking (Defaults to undef).
#
# [*auth_url*]
#   The URL used to validate tokens (Defaults to undef).
#
# [*auth_insecure*]
#   turn off verification of the certificate for ssl (Defaults to undef).
#
# [*auth_region*]
#   The authentication region (Defaults to undef).
#

class neutron::agents::metadata (
  $shared_secret,
  $package_ensure            = 'present',
  $enabled                   = true,
  $manage_service            = true,
  $debug                     = false,
  $auth_ca_cert              = $::os_service_default,
  $metadata_ip               = $::os_service_default,
  $metadata_port             = $::os_service_default,
  $metadata_protocol         = $::os_service_default,
  $metadata_workers          = $::processorcount,
  $metadata_backlog          = $::os_service_default,
  $metadata_memory_cache_ttl = $::os_service_default,
  $nova_client_cert          = $::os_service_default,
  $nova_client_priv_key      = $::os_service_default,
  $purge_config              = false,
  # DEPRECATED PARAMETERS
  $auth_password             = undef,
  $auth_tenant               = undef,
  $auth_user                 = undef,
  $auth_url                  = undef,
  $auth_insecure             = undef,
  $auth_region               = undef,
  ) {

  include ::neutron::params

  Neutron_config<||> ~> Service['neutron-metadata']
  Neutron_metadata_agent_config<||> ~> Service['neutron-metadata']

  if $auth_password {
    warning('The auth_password parameter is deprecated and was removed in Mitaka release.')
  }

  if $auth_tenant {
    warning('The auth_tenant parameter is deprecated and was removed in Mitaka release.')
  }

  if $auth_user {
    warning('The auth_user parameter is deprecated and was removed in Mitaka release.')
  }

  if $auth_url {
    warning('The auth_url parameter is deprecated and was removed in Mitaka release.')
  }

  if $auth_insecure != undef {
    warning('The auth_insecure parameter is deprecated and was removed in Mitaka release.')
  }

  if $auth_region {
    warning('The auth_region parameter is deprecated and was removed in Mitaka release.')
  }

  resources { 'neutron_metadata_agent_config':
    purge => $purge_config,
  }

  neutron_metadata_agent_config {
    'DEFAULT/debug':                          value => $debug;
    'DEFAULT/auth_ca_cert':                   value => $auth_ca_cert;
    'DEFAULT/nova_metadata_ip':               value => $metadata_ip;
    'DEFAULT/nova_metadata_port':             value => $metadata_port;
    'DEFAULT/nova_metadata_protocol':         value => $metadata_protocol;
    'DEFAULT/metadata_proxy_shared_secret':   value => $shared_secret;
    'DEFAULT/metadata_workers':               value => $metadata_workers;
    'DEFAULT/metadata_backlog':               value => $metadata_backlog;
    'DEFAULT/nova_client_cert':               value => $nova_client_cert;
    'DEFAULT/nova_client_priv_key':           value => $nova_client_priv_key;
  }

  if ! is_service_default ($metadata_memory_cache_ttl) and ($metadata_memory_cache_ttl) {
    neutron_metadata_agent_config {
      'DEFAULT/cache_url': value => "memory://?default_ttl=${metadata_memory_cache_ttl}";
    }
  } else {
    neutron_metadata_agent_config {
      'DEFAULT/cache_url': ensure => absent;
    }
  }

  if $::neutron::params::metadata_agent_package {
    Package['neutron-metadata'] -> Service['neutron-metadata']
    Package['neutron-metadata'] -> Neutron_metadata_agent_config<||>
    package { 'neutron-metadata':
      ensure  => $package_ensure,
      name    => $::neutron::params::metadata_agent_package,
      require => Package['neutron'],
      tag     => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    Package['neutron'] ~> Service['neutron-metadata']
    if $::neutron::params::metadata_agent_package {
      Package['neutron-metadata'] ~> Service['neutron-metadata']
    }
  }

  service { 'neutron-metadata':
    ensure  => $service_ensure,
    name    => $::neutron::params::metadata_agent_service,
    enable  => $enabled,
    require => Class['neutron'],
    tag     => 'neutron-service',
  }
}
