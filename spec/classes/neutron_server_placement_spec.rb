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
# Unit tests for neutron::server::placement class
#

require 'spec_helper'

describe 'neutron::server::placement' do
  let :params do
    {
      :auth_type           => 'password',
      :username            => 'nova',
      :password            => 'secrete',
      :project_domain_name => 'Default',
      :project_name        => 'services',
      :user_domain_name    => 'Default',
      :auth_url            => 'http://127.0.0.1:5000',
    }
  end

  shared_examples 'neutron server placement' do
    it 'configure neutron.conf' do
      should contain_neutron_config('placement/auth_type').with_value('password')
      should contain_neutron_config('placement/auth_url').with_value('http://127.0.0.1:5000')
      should contain_neutron_config('placement/username').with_value('nova')
      should contain_neutron_config('placement/password').with_value('secrete')
      should contain_neutron_config('placement/password').with_secret( true )
      should contain_neutron_config('placement/region_name').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('placement/project_domain_name').with_value('Default')
      should contain_neutron_config('placement/user_domain_name').with_value('Default')
      should contain_neutron_config('placement/endpoint_type').with_value('<SERVICE DEFAULT>')
    end

    context 'when overriding parameters' do
      before :each do
        params.merge!(
          :auth_url            => 'http://keystone:5000/v3',
          :auth_type           => 'password',
          :username            => 'joe',
          :region_name         => 'MyRegion',
          :project_domain_name => 'Default_2',
          :user_domain_name    => 'Default_4',
          :endpoint_type       => 'internal'
        )
      end

      it 'should configure neutron server with overrided parameters' do
        should contain_neutron_config('placement/auth_url').with_value('http://keystone:5000/v3')
        should contain_neutron_config('placement/auth_type').with_value('password')
        should contain_neutron_config('placement/username').with_value('joe')
        should contain_neutron_config('placement/password').with_value('secrete')
        should contain_neutron_config('placement/password').with_secret( true )
        should contain_neutron_config('placement/region_name').with_value('MyRegion')
        should contain_neutron_config('placement/project_domain_name').with_value('Default_2')
        should contain_neutron_config('placement/user_domain_name').with_value('Default_4')
        should contain_neutron_config('placement/endpoint_type').with_value('internal')
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

      it_behaves_like 'neutron server placement'
    end
  end
end
