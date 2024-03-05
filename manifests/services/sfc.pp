#
# Copyright (C) 2017 Red Hat Inc.
#
# Author: Bernard Cafarelli <bcafarel@redhat.com>
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
# == Class: neutron::services::sfc
#
# Configure the Service Function Chaining Neutron extension
#
# === Parameters:
#
# [*package_ensure*]
#   Whether to install the sfc extension package
#   Default to 'present'
#
# [*sfc_driver*]
#   (optional) SFC driver to use
#   Defaults to $facts['os_service_default']
#
# [*fc_driver*]
#   (optional) Flow classifier driver to use
#   Defaults to $facts['os_service_default']
#
# [*sync_db*]
#   Whether 'neutron-db-manage' should run to create and/or synchronize the
#   database with networking-sfc specific tables. Default to false
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the sfc config.
#   Default to false.
#
class neutron::services::sfc (
  $package_ensure    = 'present',
  $sfc_driver        = $facts['os_service_default'],
  $fc_driver         = $facts['os_service_default'],
  Boolean $sync_db   = false,
  $purge_config      = false,
) {

  include neutron::deps
  include neutron::params

  package { 'python-networking-sfc':
    ensure => $package_ensure,
    name   => $::neutron::params::sfc_package,
    tag    => ['openstack', 'neutron-package'],
  }

  neutron_sfc_service_config {
    'sfc/drivers':            value => $sfc_driver;
    'flowclassifier/drivers': value => $fc_driver;
  }

  resources { 'neutron_sfc_service_config':
    purge => $purge_config,
  }

  if $sync_db {
    exec { 'sfc-db-sync':
      command     => 'neutron-db-manage --subproject networking-sfc upgrade head',
      path        => '/usr/bin',
      user        => $::neutron::params::user,
      subscribe   => [
        Anchor['neutron::install::end'],
        Anchor['neutron::config::end'],
        Anchor['neutron::dbsync::begin']
      ],
      notify      => Anchor['neutron::dbsync::end'],
      refreshonly => true
    }
  }
}
