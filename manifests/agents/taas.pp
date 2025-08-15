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
# [*taas_agent_periodic_interval*]
#   (optional) Seconds between periodic task runs.
#   Defaults to $facts['os_service_default'].
#
class neutron::agents::taas (
  $package_ensure               = present,
  $taas_agent_periodic_interval = $facts['os_service_default'],
) {

  include neutron::deps
  include neutron::params

  # NOTE(tkajinam): taas provides not its own agent but l2 agent extension so
  #                 configure these options in the core plugin file so that
  #                 these options are loaded by l2 agents such as ovs-agent.
  neutron_plugin_ml2 {
    'DEFAULT/taas_agent_periodic_interval': value => $taas_agent_periodic_interval;
  }

  stdlib::ensure_packages( 'neutron-taas', {
    'ensure' => $package_ensure,
    'name'   => $::neutron::params::taas_package,
    'tag'    => ['openstack', 'neutron-package'],
  })
}
