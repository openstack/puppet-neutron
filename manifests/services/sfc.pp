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
#   (optional) Whether to install the sfc extension package.
#   Default to 'present'.
#
# [*sfc_drivers*]
#   (optional) An ordered list of service chain drivers
#   Defaults to $facts['os_service_default']
#
# [*fc_drivers*]
#   (optional) An ordered list of flow classifier drivers
#   Defaults to $facts['os_service_default']
#
# [*sync_db*]
#   (optional) Whether 'neutron-db-manage' should run to create and/or
#   synchronize the database with networking-sfc specific tables.
#   Default to false.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the sfc config.
#   Default to false.
#
# DEPRECATED PARAMETERS
#
# [*sfc_driver*]
#   (optional) SFC driver to use
#   Defaults to $facts['os_service_default']
#
# [*fc_driver*]
#   (optional) Flow classifier driver to use
#   Defaults to $facts['os_service_default']
#
class neutron::services::sfc (
  Stdlib::Ensure::Package $package_ensure = 'present',
  $sfc_drivers                            = $facts['os_service_default'],
  $fc_drivers                             = $facts['os_service_default'],
  Boolean $sync_db                        = false,
  $purge_config                           = false,
  # DEPRECATED PARAMETERS
  $sfc_driver                             = undef,
  $fc_driver                              = undef,
) {
  include neutron::deps
  include neutron::params

  if $sfc_driver != undef {
    warning('The sfc_driver parameter is deprecated. Use the sfc_drivers parameter instead.')
    $sfc_drivers_real = $sfc_driver
  } else {
    $sfc_drivers_real = $sfc_drivers
  }

  if $fc_driver != undef {
    warning('The fc_driver parameter is deprecated. Use the fc_drivers parameter instead.')
    $fc_drivers_real = $fc_driver
  } else {
    $fc_drivers_real = $fc_drivers
  }

  package { 'python-networking-sfc':
    ensure => $package_ensure,
    name   => $neutron::params::sfc_package,
    tag    => ['openstack', 'neutron-package'],
  }

  neutron_sfc_service_config {
    'sfc/drivers':            value => join(any2array($sfc_drivers_real), ',');
    'flowclassifier/drivers': value => join(any2array($fc_drivers_real), ',');
  }

  resources { 'neutron_sfc_service_config':
    purge => $purge_config,
  }

  if $sync_db {
    exec { 'sfc-db-sync':
      command     => 'neutron-db-manage --subproject networking-sfc upgrade head',
      path        => '/usr/bin',
      user        => $neutron::params::user,
      subscribe   => [
        Anchor['neutron::install::end'],
        Anchor['neutron::config::end'],
        Anchor['neutron::dbsync::begin']
      ],
      notify      => Anchor['neutron::dbsync::end'],
      refreshonly => true,
    }
  }
}
