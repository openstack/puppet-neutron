# == Class: midonet::neutron_plugin
#
# DEPERECATED !
# Install and configure Midonet Neutron Plugin. Please note that this manifest
# does not install the 'python-networking-midonet' package, it only
# configures Neutron to do so needed for this deployment.  Check out the
# MidoNet module to do so.
#
# === Parameters
#
# [*midonet_cluster_ip*]
#   IP address of the MidoNet Cluster service.
#   Defaults to '127.0.0.1'
#
# [*midonet_cluster_port*]
#   Port on which the MidoNet Cluster listens.
#   Defaults to '8181'
#
# [*keystone_username*]
#   Username with which MidoNet Cluster will authenticate against Keystone.
#   Defaults to 'neutron'
#
# [*keystone_password*]
#   Password for the user that will be used to authenticate against Keystone.
#   Defaults to $::os_service_default
#
# [*keystone_tenant*]
#   Tenant for the user that will be used to authenticate against Keystone.
#   Defaults to 'services'
#
# [*sync_db*]
#   Whether 'midonet-db-manage' should run to create and/or sync the database
#   with MidoNet specific tables.
#   Defaults to false
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the midonet config.
#   Defaults to false
#
# [*package_ensure*]
#   Whether to install the latest package, or a specific version
#   of the MidoNet plugin.
#   Defaults to 'present'
#
# DEPRECATED PARAMETERS
#
# [*midonet_api_ip*]
#   (DEPRECATED) IP address of the MidoNet API service.
#   Defaults to undef
#
# [*midonet_api_port*]
#   (DEPRECATED) Port on which the MidoNet API service listens.
#   Defaults to undef
#
# === Examples
#
# An example call would be:
#
#     class {'neutron:plugins::midonet':
#         midonet_cluster_ip    => '23.123.5.32',
#         midonet_cluster_port  => '8181',
#         keystone_username     => 'neutron',
#         keystone_password     => '32kjaxT0k3na',
#         keystone_tenant       => 'services',
#         sync_db               => true
#     }
#
# You can alternatively use the Hiera's yaml style:
#     neutron::plugin::midonet::midonet_cluster_ip: '23.213.5.32'
#     neutron::plugin::midonet::port: '8181'
#     neutron::plugin::midonet::keystone_username: 'neutron'
#     neutron::plugin::midonet::keystone_password: '32kjaxT0k3na'
#     neutron::plugin::midonet::keystone_tenant: 'services'
#     neutron::plugin::midonet::sync_db: true
#
# === Authors
#
# Midonet (http://MidoNet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class neutron::plugins::midonet (
  $midonet_cluster_ip    = '127.0.0.1',
  $midonet_cluster_port  = '8181',
  $keystone_username     = 'neutron',
  $keystone_password     = $::os_service_default,
  $keystone_tenant       = 'services',
  $sync_db               = false,
  $purge_config          = false,
  $package_ensure        = 'present',
  # DEPRECATED PARAMETERS
  $midonet_api_ip        = undef,
  $midonet_api_port      = undef,
) {

  include neutron::deps
  include neutron::params

  warning('Support for the midonet plugin has been deprecated and has no effect')
}
