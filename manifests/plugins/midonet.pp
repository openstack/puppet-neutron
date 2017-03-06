# == Class: midonet::neutron_plugin
#
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
  $keystone_tenant       = 'service',
  $sync_db               = false,
  $purge_config          = false,
  $package_ensure        = 'present',
  # DEPRECATED PARAMETERS
  $midonet_api_ip        = undef,
  $midonet_api_port      = undef,
) {

  include ::neutron::deps
  include ::neutron::params

  if $midonet_api_ip {
    # If we got midonet_api_ip here, display deprecation warning and use this value.
    warning('The midonet_api_ip parameter is going to be removed in future releases. Use the midonet_cluster_ip parameter instead.')
    $cluster_ip = $midonet_api_ip
  } else {
    $cluster_ip = $midonet_cluster_ip
  }

  if $midonet_api_port {
    # If we got midonet_api_port here, display deprecation warning and use this value.
    warning('The midonet_api_port parameter is going to be removed in future releases. Use the midonet_cluster_port parameter instead.')
    $cluster_port = $midonet_api_port
  } else {
    $cluster_port = $midonet_cluster_port
  }

  ensure_resource('file', '/etc/neutron/plugins/midonet',
    {
      ensure => directory,
      owner  => 'root',
      group  => 'neutron',
      mode   => '0640'
    }
  )

  resources { 'neutron_plugin_midonet':
    purge => $purge_config,
  }

  package { 'python-networking-midonet':
    ensure => $package_ensure,
    name   => $::neutron::params::midonet_server_package,
    tag    => ['neutron-package', 'openstack'],
    }

  neutron_plugin_midonet {
    'MIDONET/midonet_uri':  value => "http://${cluster_ip}:${cluster_port}/midonet-api";
    'MIDONET/username':     value => $keystone_username;
    'MIDONET/password':     value => $keystone_password, secret =>true;
    'MIDONET/project_id':   value => $keystone_tenant;
  }

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path  => '/etc/default/neutron-server',
      match => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line  => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::midonet_config_file}",
      tag   => 'neutron-file-line',
    }
  }

  # In RH, this link is used to start Neutron process but in Debian, it's used only
  # to manage database synchronization.
  if defined(File['/etc/neutron/plugin.ini']) {
    File <| path == '/etc/neutron/plugin.ini' |> { target => $::neutron::params::midonet_config_file }
  }
  else {
    file {'/etc/neutron/plugin.ini':
      ensure => link,
      target => $::neutron::params::midonet_config_file,
      tag    => 'neutron-config-file'
    }
  }

  if $sync_db {
    Package<| title == 'python-networking-midonet' |>     ~> Exec['midonet-db-sync']
    exec { 'midonet-db-sync':
      command     => 'neutron-db-manage --subproject networking-midonet upgrade head',
      path        => '/usr/bin',
      subscribe   => [
        Anchor['neutron::install::end'],
        Anchor['neutron::config::end'],
        Anchor['neutron::dbsync::begin'],
        Exec['neutron-db-sync']
      ],
      notify      => Anchor['neutron::dbsync::end'],
      refreshonly => true
    }
  }
}
