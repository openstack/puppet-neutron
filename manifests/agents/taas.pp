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
# == Class: neutron::agents:taas
#
# Setups Neutron TaaS agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*vlan_range_start*]
#   (optional) Starting rantge of TAAS VLAN IDs.
#   Defaults to $facts['os_service_default'].
#
# [*vlan_range_end*]
#   (optional) End rantge of TAAS VLAN IDs.
#   Defaults to $facts['os_service_default'].
#
class neutron::agents::taas (
  $package_ensure   = present,
  $vlan_range_start = $facts['os_service_default'],
  $vlan_range_end   = $facts['os_service_default'],
) {

  include neutron::deps
  include neutron::params

  neutron_plugin_ml2 {
    'taas/vlan_range_start': value => $vlan_range_start;
    'taas/vlan_range_end':   value => $vlan_range_end;
  }

  ensure_packages( 'neutron-taas', {
    'ensure' => $package_ensure,
    'name'   => $::neutron::params::taas_package,
    'tag'    => ['openstack', 'neutron-package'],
  })
}
