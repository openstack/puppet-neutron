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
# [*vpn_device_driver*]
#   (optional) Defaults to 'neutron.services.vpn.device_drivers.ipsec.OpenSwanDriver'.
#
# [*interface_driver*]
#  (optional) Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*ipsec_status_check_interval*]
#   (optional) Status check interval. Defaults to $::os_service_default.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the vpnaas config.
#   Defaults to false.
#
class neutron::agents::vpnaas (
  $package_ensure              = present,
  $vpn_device_driver           = 'neutron.services.vpn.device_drivers.ipsec.OpenSwanDriver',
  $interface_driver            = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $ipsec_status_check_interval = $::os_service_default,
  $purge_config                = false,
) {

  include ::neutron::deps
  include ::neutron::params

  case $vpn_device_driver {
    /\.OpenSwan/: {
      Package['openswan'] -> Package<| title == 'neutron-vpnaas-agent' |>
      package { 'openswan':
        ensure => present,
        name   => $::neutron::params::openswan_package,
        tag    => ['neutron-support-package', 'openstack'],
      }
    }
    /\.LibreSwan/: {
      if($::osfamily != 'Redhat') {
        fail("LibreSwan is not supported on osfamily ${::osfamily}")
      } else {
        Package['libreswan'] -> Package<| title == 'neutron-vpnaas-agent' |>
        package { 'libreswan':
          ensure => present,
          name   => $::neutron::params::libreswan_package,
          tag    => ['neutron-support-package', 'openstack'],
        }
      }
    }
    default: {
      fail("Unsupported vpn_device_driver ${vpn_device_driver}")
    }
  }

  resources { 'neutron_vpnaas_agent_config':
    purge => $purge_config,
  }

  # The VPNaaS agent loads both neutron.conf and its own file.
  # This only lists config specific to the agent.  neutron.conf supplies
  # the rest.
  neutron_vpnaas_agent_config {
    'vpnagent/vpn_device_driver':        value => $vpn_device_driver;
    'ipsec/ipsec_status_check_interval': value => $ipsec_status_check_interval;
    'DEFAULT/interface_driver':          value => $interface_driver;
  }

  if $::neutron::params::vpnaas_agent_package {
    ensure_resource( 'package', 'neutron-vpnaas-agent', {
      'ensure' => $package_ensure,
      'name'   => $::neutron::params::vpnaas_agent_package,
      'tag'    => ['openstack', 'neutron-package'],
    })
  }
}
