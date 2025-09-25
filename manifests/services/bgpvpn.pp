#
# Copyright (C) 2017 Red Hat Inc.
#
# Author: Ricardo Noriega <rnoriega@redhat.com>
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
# == Class: neutron::services::bgpvpn
#
# Configure BGPVPN Neutron API
#
# === Parameters:
#
# [*package_ensure*]
#   (optional) Whether to install the bgpvpn service package.
#   Default to 'present'.
#
# [*service_providers*]
#   (optional) Array of allowed service types includes fwaas
#   Must be in form: <service_type>:<name>:<driver>[:default]
#   Defaults to 'BGPVPN:Dummy:networking_bgpvpn.neutron.services.service_drivers.driver_api.BGPVPNDriver:default'
#
# [*sync_db*]
#   (optional) Whether 'neutron-db-manage' should run to create and/or
#   synchronize the database with networking-bgpvpn specific tables.
#   Default to false.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the bgpvpn config.
#   Default to false.
#
class neutron::services::bgpvpn (
  Stdlib::Ensure::Package $package_ensure = 'present',
  $service_providers                      = 'BGPVPN:Dummy:networking_bgpvpn.neutron.services.service_drivers.driver_api.BGPVPNDriver:default',
  Boolean $sync_db                        = false,
  $purge_config                           = false,
) {
  include neutron::deps
  include neutron::params

  package { 'python-networking-bgpvpn':
    ensure => $package_ensure,
    name   => $neutron::params::bgpvpn_plugin_package,
    tag    => ['openstack', 'neutron-package'],
  }

  neutron_bgpvpn_service_config { 'service_providers/service_provider':
    value => $service_providers,
  }

  resources { 'neutron_bgpvpn_service_config':
    purge => $purge_config,
  }

  if $sync_db {
    exec { 'bgpvpn-db-sync':
      command     => 'neutron-db-manage --subproject networking-bgpvpn upgrade head',
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
