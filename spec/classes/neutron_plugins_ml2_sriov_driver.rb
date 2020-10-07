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
# Unit tests for neutron::plugins::ml2::sriov_driver class

required 'spec_helper'

describe 'neutron::plugins::ml2::sriov_driver' do

  let :default_params do
    {
        :vnic_type_blacklist  => []
    }
  end

  context 'when vnic_type_blacklist is not empty list' do
    before :each do
      params.merge!(:vnic_type_blacklist => ['direct'])
    end

    it 'should configure direct in vnic_type_blacklist' do
      shoud contain_neutron_plugin_ml2('sriov_driver/vnic_type_blacklist').with_value("direct")
    end
  end
end
