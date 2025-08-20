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
# neutron::plugins::ml2::ovs_driver
#
# === Parameters:
#
# [*vnic_type_prohibit_list*]
#  (optional) list of VNIC types for which support in Neutron is
#  administratively prohibited by the OVS mechanism driver
#  Defaults to []
#
class neutron::plugins::ml2::ovs_driver (
  Array $vnic_type_prohibit_list = [],
) {
  if !empty($vnic_type_prohibit_list) {
    neutron_plugin_ml2 {
      'ovs_driver/vnic_type_prohibit_list': value => join($vnic_type_prohibit_list, ',');
    }
  } else {
    neutron_plugin_ml2 {
      'ovs_driver/vnic_type_prohibit_list': value => $facts['os_service_default'];
    }
  }
}
