#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: neutron::agents:vpnaas
#
# Setups Neutron VPN agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enabled*]
#   (optional) Enable state for service. Defaults to 'true'.
#
# [*vpn_device_driver*]
#   (optional) Defaults to 'neutron.services.vpn.device_drivers.ipsec.OpenSwanDriver'.
#
# [*ipsec_status_check_interval*]
#   (optional) Status check interval. Defaults to '60'.
#
class neutron::agents::vpnaas (
  $package_ensure              = present,
  $enabled                     = true,
  $vpn_device_driver           = 'neutron.services.vpn.device_drivers.ipsec.OpenSwanDriver',
  $ipsec_status_check_interval = '60'
) {

  include neutron::params

  Neutron_config<||>            ~> Service['neutron-vpnaas-service']
  Neutron_vpnaas_agent_config<||> ~> Service['neutron-vpnaas-service']

  case $vpn_device_driver {
    /\.OpenSwan/: {
      Package['openswan'] -> Package<| title == 'neutron-vpnaas-agent' |>
      package { 'openswan':
        ensure => present,
        name   => $::neutron::params::openswan_package,
      }
    }
    default: {
      fail("Unsupported vpn_device_driver ${vpn_device_driver}")
    }
  }

  # The VPNaaS agent loads both neutron.ini and its own file.
  # This only lists config specific to the agent.  neutron.ini supplies
  # the rest.
  neutron_vpnaas_agent_config {
    'vpnagent/vpn_device_driver':        value => $vpn_device_driver;
    'ipsec/ipsec_status_check_interval': value => $ipsec_status_check_interval;
  }

  if $::neutron::params::vpnaas_agent_package {
    Package['neutron']            -> Package['neutron-vpnaas-agent']
    Package['neutron-vpnaas-agent'] -> Neutron_vpnaas_agent_config<||>
    package { 'neutron-vpnaas-agent':
      ensure  => $package_ensure,
      name    => $::neutron::params::vpnaas_agent_package,
    }
  } else {
    # Some platforms (RedHat) do not provide a neutron VPNaaS agent package.
    # The neutron VPNaaS agent config file is provided by the neutron package.
    Package['neutron'] -> Neutron_vpnaas_agent_config<||>
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'neutron-vpnaas-service':
    ensure  => $ensure,
    name    => $::neutron::params::vpnaas_agent_service,
    enable  => $enabled,
    require => Class['neutron'],
  }
}
