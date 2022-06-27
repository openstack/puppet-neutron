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
# Unit tests for neutron::server::notifications class
#

require 'spec_helper'

describe 'neutron::server::notifications' do
  let :params do
    {}
  end

  let :pre_condition do
    "class { 'neutron::server::notifications::nova':
       password => 'secrete',
     }"
  end

  shared_examples 'neutron server notifications' do
    it 'configure neutron.conf' do
      should contain_neutron_config('DEFAULT/send_events_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/http_retries').with_value('<SERVICE DEFAULT>')
    end

    context 'when overriding parameters' do
      before :each do
        params.merge!(
          :send_events_interval => '10',
          :http_retries         => 3,
        )
      end

      it 'should configure neutron server with overridden parameters' do
        should contain_neutron_config('DEFAULT/send_events_interval').with_value('10')
        should contain_neutron_config('DEFAULT/http_retries').with_value(3)
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

      it_behaves_like 'neutron server notifications'
    end
  end
end
