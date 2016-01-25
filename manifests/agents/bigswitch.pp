# == Class: neutron::agents::bigswitch
#
# Installs and configures the Big Switch agent and lldp
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*lldp_enabled*]
#   (optional) The state of the neutron-bsn-lldp service
#   Defaults to true
#
# [*agent_enabled*]
#   (optional) The state of the neutron-bsn-agent service
#   Defaults to false
#
#
class neutron::agents::bigswitch (
  $package_ensure = 'present',
  $lldp_enabled   = true,
  $agent_enabled  = false,
) {

  if($::osfamily != 'Redhat') {
    fail("Unsupported osfamily ${::osfamily}")
  }

  require ::neutron::plugins::ml2::bigswitch

  package { 'bigswitch-lldp':
    ensure => $package_ensure,
    name   => $::neutron::params::bigswitch_lldp_package,
    tag    => 'openstack',
  }

  package { 'bigswitch-agent':
    ensure => $package_ensure,
    name   => $::neutron::params::bigswitch_agent_package,
    tag    => 'openstack',
  }

  if $lldp_enabled {
    $lldp_service_ensure = 'running'
  } else {
    $lldp_service_ensure = 'stopped'
  }

  if $agent_enabled {
    $agent_service_ensure = 'running'
  } else {
    $agent_service_ensure = 'stopped'
  }

  service { 'bigswitch-lldp':
    ensure  => $lldp_service_ensure,
    name    => $::neutron::params::bigswitch_lldp_service,
    enable  => $lldp_enabled,
    require => [Class['neutron'], Package['bigswitch-lldp']],
    tag     => 'neutron-service',
  }

  service { 'bigswitch-agent':
    ensure  => $agent_service_ensure,
    name    => $::neutron::params::bigswitch_agent_service,
    enable  => $agent_enabled,
    require => [Class['neutron'], Package['bigswitch-agent']],
    tag     => 'neutron-service',
  }
}
