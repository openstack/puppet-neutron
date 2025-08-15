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
# == Class: neutron::agents:metering
#
# Setups Neutron metering agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enabled*]
#   (optional) Enable state for service. Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   (optional) Show debugging output in log. Defaults to $facts['os_service_default'].
#
# [*interface_driver*]
#   (optional) The driver used to manage the virtual interface.
#   Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*driver*]
#   (optional) Metering driver.
#   Defaults to 'neutron.services.metering.drivers.noop.noop_driver.NoopMeteringDriver'.
#
# [*measure_interval*]
#   (optional) Interval between two metering measures.
#   Defaults to 30.
#
# [*report_interval*]
#   (optional) Interval between two metering reports.
#   Defaults to 300.
#
# [*rpc_response_max_timeout*]
#   (Optional) Maximum seconds to wait for a response from an RPC call
#   Defaults to: $facts['os_service_default']
#
# [*agent_report_interval*]
#   (optional) Set the agent report interval. By default the global report
#   interval in neutron.conf ([agent]/report_interval) is used. This parameter
#   can be used to override the reporting interval for the metering-agent.
#   Defaults to $facts['os_service_default']
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the metering config.
#   Defaults to false.
#
class neutron::agents::metering (
  $package_ensure           = present,
  Boolean $enabled          = true,
  Boolean $manage_service   = true,
  $debug                    = $facts['os_service_default'],
  $interface_driver         = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $driver                   = 'neutron.services.metering.drivers.noop.noop_driver.NoopMeteringDriver',
  $measure_interval         = $facts['os_service_default'],
  $report_interval          = $facts['os_service_default'],
  $rpc_response_max_timeout = $facts['os_service_default'],
  $agent_report_interval    = $facts['os_service_default'],
  Boolean $purge_config     = false,
) {

  include neutron::deps
  include neutron::params

  resources { 'neutron_metering_agent_config':
    purge => $purge_config,
  }

  # The metering agent loads both neutron.conf and its own file.
  # This only lists config specific to the agent.  neutron.conf supplies
  # the rest.
  neutron_metering_agent_config {
    'DEFAULT/debug':                    value => $debug;
    'DEFAULT/interface_driver':         value => $interface_driver;
    'DEFAULT/driver':                   value => $driver;
    'DEFAULT/measure_interval':         value => $measure_interval;
    'DEFAULT/report_interval':          value => $report_interval;
    'DEFAULT/rpc_response_max_timeout': value => $rpc_response_max_timeout;
    'agent/report_interval':            value => $agent_report_interval;
  }

  if $neutron::params::metering_agent_package {
    package { 'neutron-metering-agent':
      ensure => $package_ensure,
      name   => $neutron::params::metering_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-metering-service':
      ensure => $service_ensure,
      name   => $neutron::params::metering_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
    Neutron_metering_agent_config<||> ~> Service['neutron-metering-service']
  }
}
