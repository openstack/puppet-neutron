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
# Unit tests for neutron::plugins::ml2::ovs_driver class

require 'spec_helper'

describe 'neutron::plugins::ml2::ovs_driver' do

  shared_examples 'neutron::plugins::ml2::ovs_driver' do
    context 'with defaults' do
      let :params do
        {}
      end

      it 'should set the default values' do
        should contain_neutron_plugin_ml2('ovs_driver/vnic_type_prohibit_list').with_value("<SERVICE DEFAULT>")
      end
    end

    context 'when vnic_type_prohibit_list is not empty list' do
      let :params do
        { :vnic_type_prohibit_list => ['direct'] }
      end

      it 'should configure direct in vnic_type_prohibit_list' do
        should contain_neutron_plugin_ml2('ovs_driver/vnic_type_prohibit_list').with_value("direct")
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::plugins::ml2::ovs_driver'
    end
  end
end
