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
# == Class: neutron::plugins::ml2::bagpipe
#
# Installs and configures the Bagpipe extensions for BGPVPN service
#
# === Parameters
#
# [*bagpipe_bgp_port*]
#   BGP component API port
#   Defaults to $::os_service_default
#
# [*mpls_bridge*]
#   OVS bridge to use
#   Defaults to $::os_service_default
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
class neutron::plugins::ml2::bagpipe (
  $bagpipe_bgp_port        = $::os_service_default,
  $mpls_bridge             = $::os_service_default,
  $package_ensure          = 'present',
) {

  include ::neutron::deps
  include ::neutron::params
  require ::neutron::plugins::ml2

  neutron_plugin_ml2 {
    'bagpipe/bagpipe_bgp_port':       value => $bagpipe_bgp_port;
    'bagpipe/mpls_bridge':            value => $mpls_bridge;
  }

  if $::neutron::params::bgpvpn_bagpipe_package {
    package { 'python-networking-bagpipe':
      ensure => $package_ensure,
      name   => $::neutron::params::bgpvpn_bagpipe_package,
      tag    => 'openstack',
    }
  }
}
