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
#   Debug. Defaults to $facts['os_service_default'].
#
# [*auth_ca_cert*]
#   CA cert to check against with for ssl keystone. (Defaults to $facts['os_service_default'])
#
# [*nova_client_cert*]
#   Client certificate for nova metadata api server. (Defaults to $facts['os_service_default'])
#
# [*nova_client_priv_key*]
#   Private key of client certificate. (Defaults to $facts['os_service_default'])
#
# [*metadata_host*]
#   The hostname of the metadata service. Defaults to $facts['os_service_default'].
#
# [*metadata_port*]
#   The TCP port of the metadata service. Defaults to $facts['os_service_default'].
#
# [*metadata_protocol*]
#   The protocol to use for requests to Nova metadata server. Defaults to $facts['os_service_default'].
#
# [*metadata_workers*]
#   (optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to: $facts['os_workers']
#
# [*metadata_backlog*]
#   (optional) Number of backlog requests to configure the metadata server socket with.
#   Defaults to $facts['os_service_default']
#
# [*metadata_insecure*]
#   (optional) Allow to perform insecure SSL (https) requests to nova metadata.
#   Defaults to $facts['os_service_default']
#
# [*report_interval*]
#   (optional) Set the agent report interval. By default the global report
#   interval in neutron.conf ([agent]/report_interval) is used. This parameter
#   can be used to override the reporting interval for the sriov-agent.
#   Defaults to $facts['os_service_default']
#
# [*rpc_response_max_timeout*]
#   (Optional) Maximum seconds to wait for a response from an RPC call
#   Defaults to: $facts['os_service_default']
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the metadata config.
#   Defaults to false.
#
# DEPRECATED PRAMETERS
#
# [*metadata_memory_cache_ttl*]
#   (optional) Specifies time in seconds a metadata cache entry is valid in
#   memory caching backend.
#   Defaults to undef
#
class neutron::agents::metadata (
  $shared_secret,
  $package_ensure            = 'present',
  Boolean $enabled           = true,
  Boolean $manage_service    = true,
  $debug                     = $facts['os_service_default'],
  $auth_ca_cert              = $facts['os_service_default'],
  $metadata_host             = $facts['os_service_default'],
  $metadata_port             = $facts['os_service_default'],
  $metadata_protocol         = $facts['os_service_default'],
  $metadata_workers          = $facts['os_workers'],
  $metadata_backlog          = $facts['os_service_default'],
  $metadata_insecure         = $facts['os_service_default'],
  $nova_client_cert          = $facts['os_service_default'],
  $nova_client_priv_key      = $facts['os_service_default'],
  $report_interval           = $facts['os_service_default'],
  $rpc_response_max_timeout  = $facts['os_service_default'],
  Boolean $purge_config      = false,
  # DEPRECATED PARAMETERS
  $metadata_memory_cache_ttl = undef,
) {

  include neutron::deps
  include neutron::params

  if metadata_memory_cache_ttl {
    warning('The metadata_memotry_cache_ttl parameter is deprecated and has no effect.')
  }

  resources { 'neutron_metadata_agent_config':
    purge => $purge_config,
  }

  neutron_metadata_agent_config {
    'DEFAULT/debug':                          value => $debug;
    'DEFAULT/auth_ca_cert':                   value => $auth_ca_cert;
    'DEFAULT/nova_metadata_host':             value => $metadata_host;
    'DEFAULT/nova_metadata_port':             value => $metadata_port;
    'DEFAULT/nova_metadata_protocol':         value => $metadata_protocol;
    'DEFAULT/nova_metadata_insecure':         value => $metadata_insecure;
    'DEFAULT/metadata_proxy_shared_secret':   value => $shared_secret, secret => true;
    'DEFAULT/metadata_workers':               value => $metadata_workers;
    'DEFAULT/metadata_backlog':               value => $metadata_backlog;
    'DEFAULT/nova_client_cert':               value => $nova_client_cert;
    'DEFAULT/nova_client_priv_key':           value => $nova_client_priv_key;
    'agent/report_interval':                  value => $report_interval;
    'DEFAULT/rpc_response_max_timeout':       value => $rpc_response_max_timeout;
  }

  # TODO(tkajinam): Remove this after 2024.1 release
  neutron_metadata_agent_config {
    'DEFAULT/cache_url': ensure => absent;
  }

  if $::neutron::params::metadata_agent_package {
    package { 'neutron-metadata':
      ensure => $package_ensure,
      name   => $::neutron::params::metadata_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-metadata':
      ensure => $service_ensure,
      name   => $::neutron::params::metadata_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
    Neutron_metadata_agent_config<||> ~> Service['neutron-metadata']
  }
}
