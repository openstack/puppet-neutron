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
# == DEPRECATED
# This class has been deprecated in favor of using the parameter in
# neutron::server::service_provider
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
# [*cert_manager_type*]
#   (optional) Certificate manager type to use for lbaas.
#   Defaults to $::os_service_default
#   Example: barbican
#
# [*cert_storage_path*]
#   (optional) The location to store certificates locally.
#   Defaults to $::os_service_default
#   Example: /var/lib/neutron-lbaas/certificates/
#
# [*barbican_auth*]
#  (optional) Name of the barbican authentication method to use.
#  Defaults to $::os_service_default
#  Example: barbican_acl_auth
#
class neutron::services::lbaas (
  $cert_manager_type           = $::os_service_default,
  $cert_storage_path           = $::os_service_default,
  $barbican_auth               = $::os_service_default,
  $ensure_lbaas_driver_package = 'present',
) {

  include ::neutron::deps
  include ::neutron::params

  if $ensure_lbaas_driver_package {
    if ($::os_package_type == 'debian') {
      ensure_packages(['python3-neutron-lbaas'], {
        ensure => $ensure_lbaas_driver_package,
        tag    => ['openstack', 'neutron-package']
      })
    } else {
      ensure_packages(['python-neutron-lbaas'], {
        ensure => $ensure_lbaas_driver_package,
        tag    => ['openstack', 'neutron-package']
      })
    }
  }

  neutron_config {
    'certificates/cert_manager_type':           value => $cert_manager_type;
    'certificates/storage_path':                value => $cert_storage_path;
    'certificates/barbican_auth':               value => $barbican_auth;
  }
}
