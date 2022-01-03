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
# Unit tests for neutron::server::notifications::ironic class
#

require 'spec_helper'

describe 'neutron::server::notifications::ironic' do
  let :params do
    {
      :auth_type           => 'password',
      :username            => 'ironic',
      :password            => 'secrete',
      :project_domain_name => 'Default',
      :project_name        => 'services',
      :user_domain_name    => 'Default',
      :auth_url            => 'http://127.0.0.1:5000',
    }
  end

  shared_examples 'neutron::server::notifications::ironic' do
    it 'configure neutron.conf' do
      should contain_neutron_config('ironic/auth_type').with_value('password')
      should contain_neutron_config('ironic/user_domain_name').with_value('Default')
      should contain_neutron_config('ironic/username').with_value('ironic')
      should contain_neutron_config('ironic/password').with_value('secrete').with_secret( true )
      should contain_neutron_config('ironic/project_domain_name').with_value('Default')
      should contain_neutron_config('ironic/project_name').with_value('services')
      should contain_neutron_config('ironic/system_scope').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('ironic/auth_url').with_value('http://127.0.0.1:5000')
      should contain_neutron_config('ironic/region_name').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('ironic/valid_interfaces').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('ironic/enable_notifications').with_value('<SERVICE DEFAULT>')
    end

    context 'when overriding parameters' do
      before :each do
        params.merge!(
          :auth_type            => 'password',
          :user_domain_name     => 'Default_2',
          :username             => 'joe',
          :project_domain_name  => 'Default_1',
          :project_name         => 'alt_services',
          :auth_url             => 'http://keystone:5000/v3',
          :region_name          => 'MyRegion',
          :valid_interfaces     => 'internal,public',
          :enable_notifications => false,
        )
      end

      it 'should configure neutron server with overrided parameters' do
        should contain_neutron_config('ironic/auth_type').with_value('password')
        should contain_neutron_config('ironic/user_domain_name').with_value('Default_2')
        should contain_neutron_config('ironic/username').with_value('joe')
        should contain_neutron_config('ironic/password').with_value('secrete').with_secret(true)
        should contain_neutron_config('ironic/project_domain_name').with_value('Default_1')
        should contain_neutron_config('ironic/project_name').with_value('alt_services')
        should contain_neutron_config('ironic/system_scope').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('ironic/auth_url').with_value('http://keystone:5000/v3')
        should contain_neutron_config('ironic/region_name').with_value('MyRegion')
        should contain_neutron_config('ironic/valid_interfaces').with_value('internal,public')
        should contain_neutron_config('ironic/enable_notifications').with_value(false)
      end
    end

    context 'when valid_interfaces is an array' do
      before :each do
        params.merge!(
          :valid_interfaces => ['internal', 'public']
        )
      end

      it 'should configure the valid_interfaces parameter with a commma-separated string' do
        should contain_neutron_config('ironic/valid_interfaces').with_value('internal,public')
      end
    end

    context 'when system_scope is set' do
      before :each do
        params.merge!(
          :system_scope => 'all'
        )
      end

      it 'should configure system scope credential' do
        should contain_neutron_config('ironic/project_domain_name').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('ironic/project_name').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('ironic/system_scope').with_value('all')
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

      it_behaves_like 'neutron::server::notifications::ironic'
    end
  end
end
