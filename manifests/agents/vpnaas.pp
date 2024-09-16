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
#   (optional) The vpn device drivers Neutron will us.
#   Defaults to 'neutron_vpnaas.services.vpn.device_drivers.ipsec.OpenSwanDriver'.
#
# [*interface_driver*]
#   (optional) The driver used to manage the virtual interface.
#   Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*ipsec_status_check_interval*]
#   (optional) Status check interval. Defaults to $facts['os_service_default'].
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the vpnaas config.
#   Defaults to false.
#
class neutron::agents::vpnaas (
  $package_ensure              = present,
  $vpn_device_driver           = 'neutron_vpnaas.services.vpn.device_drivers.ipsec.OpenSwanDriver',
  $interface_driver            = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $ipsec_status_check_interval = $facts['os_service_default'],
  Boolean $purge_config        = false,
) {

  include neutron::deps
  include neutron::params

  case $vpn_device_driver {
    /\.OpenSwan/: {
      warning("Support for OpenSwan has been deprecated, because of lack of \
openswan package in distributions")
    }
    /\.LibreSwan/: {
      Package['libreswan'] -> Package<| title == 'neutron-vpnaas-agent' |>
      ensure_packages( 'libreswan', {
        'ensure' => present,
        'name'   => $::neutron::params::libreswan_package,
        'tag'    => ['openstack', 'neutron-support-package'],
      })
    }
    /\.StrongSwan/: {
      Package['strongswan'] -> Package<| title == 'neutron-vpnaas-agent' |>
      ensure_packages( 'strongswan', {
        'ensure' => present,
        'name'   => $::neutron::params::strongswan_package,
        'tag'    => ['openstack', 'neutron-support-package'],
      })
    }
    default: {
      fail("Unsupported vpn_device_driver ${vpn_device_driver}")
    }
  }

  resources { 'neutron_vpnaas_agent_config':
    purge => $purge_config,
  }

  # neutron-vpnaas-agent is not an independent service but is integrated into
  # l3 agent.
  Neutron_vpnaas_agent_config<||> ~> Service<| title == 'neutron-l3' |>

  # The VPNaaS agent loads both neutron.conf and its own file.
  # This only lists config specific to the agent.  neutron.conf supplies
  # the rest.
  neutron_vpnaas_agent_config {
    'vpnagent/vpn_device_driver':        value => $vpn_device_driver;
    'ipsec/ipsec_status_check_interval': value => $ipsec_status_check_interval;
    'DEFAULT/interface_driver':          value => $interface_driver;
  }

  ensure_packages( 'neutron-vpnaas-agent', {
    'ensure' => $package_ensure,
    'name'   => $::neutron::params::vpnaas_agent_package,
    'tag'    => ['openstack', 'neutron-package'],
  })
}
