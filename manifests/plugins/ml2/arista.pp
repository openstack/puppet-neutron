#
# Copyright (C) 2016 Matthew J. Black
#
# Author: Matthew J. Black <mjblack@gmail.com>
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
# == Class: neutron::plugins::ml2::arista
#
# === Parameters
#
# [*eapi_host*]
#   (required) The Arista EOS IP address.
#
# [*eapi_username*]
#   (required) The Arista EOS api username.
#
# [*eapi_password*]
#   (required) The Arista EOS api password.
#
# [*region_name*]
#   (optional) Region name that is assigned to the OpenStack controller.
#   This setting must be set if multiple regions are using the same Arista
#   hardware.
#   Defaults to $facts['os_service_default']
#
# [*sync_interval*]
#   (optional) Sync interval in seconds between neutron plugin and EOS.
#   Defaults to $facts['os_service_default']
#
# [*use_fqdn*]
#   (optional) Defines if hostnames are sent to Arista EOS as FQDNS
#   Defaults to $facts['os_service_default']
#
# [*conn_timeout*]
#   (optional) Connection timeout interval in seconds.
#   Defaults to $facts['os_service_default']
#
# [*package_ensure*]
#   (optional) The intended state of the python-networking-baremetal
#   package, i.e. any of the possible values of the 'ensure'
#   property for a package resource type.
#   Defaults to 'present'
#
class neutron::plugins::ml2::arista(
  $eapi_host,
  $eapi_username,
  $eapi_password,
  $region_name    = $facts['os_service_default'],
  $sync_interval  = $facts['os_service_default'],
  $conn_timeout   = $facts['os_service_default'],
  $use_fqdn       = $facts['os_service_default'],
  $package_ensure = 'present'
) {

  include neutron::deps
  require neutron::plugins::ml2

  neutron_plugin_ml2 {
    'ml2_arista/eapi_host'    : value => $eapi_host;
    'ml2_arista/eapi_username': value => $eapi_username;
    'ml2_arista/eapi_password': value => $eapi_password, secret => true;
    'ml2_arista/region_name'  : value => $region_name;
    'ml2_arista/sync_interval': value => $sync_interval;
    'ml2_arista/conn_timeout' : value => $conn_timeout;
    'ml2_arista/use_fqdn'     : value => $use_fqdn;
  }

  package { 'python-networking-arista':
    ensure => $package_ensure,
    name   => $neutron::params::arista_plugin_package,
    tag    => ['openstack', 'neutron-plugin-ml2-package'],
  }
}
