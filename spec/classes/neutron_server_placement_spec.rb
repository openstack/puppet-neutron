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
      :password  => 'secrete',
    }
  end

  shared_examples 'neutron server placement' do
    it 'configure neutron.conf' do
      should contain_neutron_config('placement/auth_type').with_value('password')
      should contain_neutron_config('placement/project_domain_name').with_value('Default')
      should contain_neutron_config('placement/project_name').with_value('services')
      should contain_neutron_config('placement/system_scope').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('placement/user_domain_name').with_value('Default')
      should contain_neutron_config('placement/username').with_value('placement')
      should contain_neutron_config('placement/password').with_value('secrete').with_secret( true )
      should contain_neutron_config('placement/auth_url').with_value('http://127.0.0.1:5000')
      should contain_neutron_config('placement/region_name').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('placement/endpoint_type').with_value('<SERVICE DEFAULT>')
    end

    context 'when overriding parameters' do
      before :each do
        params.merge!(
          :auth_type           => 'password',
          :project_domain_name => 'Default_2',
          :project_name        => 'alt_services',
          :user_domain_name    => 'Default_4',
          :username            => 'joe',
          :auth_url            => 'http://keystone:5000/v3',
          :region_name         => 'MyRegion',
          :endpoint_type       => 'internal'
        )
      end

      it 'should configure neutron server with overridden parameters' do
        should contain_neutron_config('placement/auth_type').with_value('password')
        should contain_neutron_config('placement/project_domain_name').with_value('Default_2')
        should contain_neutron_config('placement/project_name').with_value('alt_services')
        should contain_neutron_config('placement/system_scope').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('placement/user_domain_name').with_value('Default_4')
        should contain_neutron_config('placement/username').with_value('joe')
        should contain_neutron_config('placement/password').with_value('secrete').with_secret(true)
        should contain_neutron_config('placement/auth_url').with_value('http://keystone:5000/v3')
        should contain_neutron_config('placement/region_name').with_value('MyRegion')
        should contain_neutron_config('placement/endpoint_type').with_value('internal')
      end
    end

    context 'when system_scope is set' do
      before do
        params.merge!(
          :system_scope => 'all'
        )
      end

      it 'configures system-scoped credential' do
        is_expected.to contain_neutron_config('placement/project_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_config('placement/project_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_config('placement/system_scope').with_value('all')
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
