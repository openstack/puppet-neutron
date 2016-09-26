#
# Copyright (C) 2015 Kylinos Inc.
#
# Author: nanhai liao <nanhai.liao@kylin-cloud.com>
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
# == DEPRECATED
# This class has been deprecated in favor of using the parameter in
# neutron::server::service_provider
#
# == Class: neutron::services::vpnaas
#
# Configure the VPN as a Service Neutron Plugin
#
# === Parameters:
#
# [*package_ensure*]
#   (required) Whether or not to install the VPNaas Neutron plugin package
#   Defaults to present
#
# [*service_providers*]
#   (optional) Array of allowed service types or '<SERVICE DEFAULT>'.
#   Note: The default upstream value is empty.
#         If you plan to activate VPNaaS service, you'll need to set this
#         parameter otherwise neutron-server won't start correctly.
#         See https://bugs.launchpad.net/puppet-neutron/+bug/1538971
#   Must be in form <service_type>:<name>:<driver>[:default].
#   Defaults to $::os_service_default
#
class neutron::services::vpnaas (
  $package_ensure    = 'present',
  $service_providers = $::os_service_default,
) {

  include ::neutron::params
  if !is_service_default($service_providers) {
    warning("service_providers in neutron::services::vpnaas is deprecated in newton release, \
please use service provider in neutron::server class")
  }

  # agent package contains both agent and service resources
  ensure_resource( 'package', 'neutron-vpnaas-agent', {
    ensure => $package_ensure,
    name   => $::neutron::params::vpnaas_agent_package,
    tag    => ['openstack', 'neutron-package'],
  })

  if !is_service_default($service_providers) {
    # default value is uncommented setting, so we should not touch it at all
    neutron_vpnaas_service_config { 'service_providers/service_provider':
      value => $service_providers,
    }
  }
}
