#
# Copyright (C) 2015 Red Hat Inc.
#
# Author: Martin Magr <mmagr@redhat.com>
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
#
# == Class: neutron::services::lbaas
#
# Configure the Loadbalancer as a Service Neutron Plugin
#
# === Parameters:
#
# [*ensure_lbaas_driver_package*]
#   (optional) Whether to install the lbaas driver package
#   Defaults to 'present'
#
# [*service_providers*]
#   (optional) Array of allowed service types or '<SERVICE DEFAULT>'.
#   Note: The default upstream value is empty.
#         If you plan to activate LBaaS service, you'll need to set this
#         parameter otherwise neutron-server won't start correctly.
#         See https://bugs.launchpad.net/puppet-neutron/+bug/1535382/comments/1
#   Must be in form <service_type>:<name>:<driver>[:default].
#   Defaults to $::os_service_default
#
# === Deprecated Parameters
#
# [*package_ensure*]
#   (optional) Deprecated. Used to install the lbaas v2 agent. This was moved into
#   neutron::agents::lbaas as the lbaas services handles scheduling of new load balancers
#   Defaults to false
#
class neutron::services::lbaas (
  $ensure_lbaas_driver_package = 'present',
  $service_providers           = $::os_service_default,
  # DEPRECATED
  $package_ensure              = false,
) {

  include ::neutron::params

  if $ensure_lbaas_driver_package {
    ensure_packages(['python-neutron-lbaas'], {
      ensure => $ensure_lbaas_driver_package,
      tag    => ['openstack', 'neutron-package']
    })
  }
  if $package_ensure {
    warning('Package ensure is deprecated. The neutron::agents::lbaas class should be used to install the agent')
    # agent package contains both agent and service resources
    ensure_resource( 'package', 'neutron-lbaas-agent', {
      ensure => $package_ensure,
      name   => $::neutron::params::lbaas_agent_package,
      tag    => ['openstack', 'neutron-package'],
    })
  }
  if !is_service_default($service_providers) {
    # default value is uncommented setting, so we should not touch it at all
    neutron_lbaas_service_config { 'service_providers/service_provider':
      value => $service_providers,
    }
    Package<| tag == 'neutron-package' |> -> Neutron_lbaas_service_config<||>
  }
}
