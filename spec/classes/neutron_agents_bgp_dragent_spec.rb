# Copyright (C) 2018 Binero AB.
#
# Author: Tobias Urdin <tobias.urdin@binero.se>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'neutron::agents::bgp_dragent' do
  let :default_params do
    {
      :bgp_speaker_driver => 'neutron_dynamic_routing.services.bgp.agent.driver.os_ken.driver.OsKenBgpDriver',
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron::agents::bgp_dragent' do
    context 'with default params' do
      it { should contain_class('neutron::deps') }
      it { should contain_class('neutron::params') }

      it { should contain_resources('neutron_bgp_dragent_config').with_purge(false) }

      it { should contain_neutron_bgp_dragent_config('bgp/bgp_speaker_driver').with_value(default_params[:bgp_speaker_driver]) }
      it { should contain_neutron_bgp_dragent_config('bgp/bgp_router_id').with_value(facts[:networking]['ip']) }

      it { should contain_package('neutron-bgp-dragent').with(
        :ensure => 'present',
        :name   => platform_params[:bgp_dragent_package],
        :tag    => ['openstack', 'neutron-package'],
      )}

      it { should contain_service('neutron-bgp-dragent').with(
        :ensure => 'running',
        :name   => platform_params[:bgp_dragent_service],
        :enable => true,
        :tag    => 'neutron-service',
      )}
    end

    context 'with overridden params' do
      before do
        params.merge!(
          :package_ensure     => 'absent',
          :enabled            => false,
          :bgp_speaker_driver => 'FakeDriver',
          :bgp_router_id      => '4.3.2.1',
          :purge_config       => true
        )
      end

      it { should contain_resources('neutron_bgp_dragent_config').with_purge(true) }
      it { should contain_neutron_bgp_dragent_config('bgp/bgp_speaker_driver').with_value('FakeDriver') }
      it { should contain_neutron_bgp_dragent_config('bgp/bgp_router_id').with_value('4.3.2.1') }

      it { should contain_package('neutron-bgp-dragent').with(
        :ensure => 'absent',
        :name   => platform_params[:bgp_dragent_package],
        :tag    => ['openstack', 'neutron-package'],
      )}

      it { should contain_service('neutron-bgp-dragent').with(
        :ensure => 'stopped',
        :name   => platform_params[:bgp_dragent_service],
        :enable => false,
        :tag    => 'neutron-service',
      )}
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not manage the service' do
        should_not contain_service('neutron-bgp-dragent')
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:os]['family']
        when 'RedHat'
          {
            :bgp_dragent_package => 'openstack-neutron-bgp-dragent',
            :bgp_dragent_service => 'neutron-bgp-dragent',
          }
        when 'Debian'
          {
            :bgp_dragent_package => 'neutron-bgp-dragent',
            :bgp_dragent_service => 'neutron-bgp-dragent',
          }
        end
      end

      it_behaves_like 'neutron::agents::bgp_dragent'
    end
  end
end
