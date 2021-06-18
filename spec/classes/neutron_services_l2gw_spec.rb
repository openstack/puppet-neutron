# Copyright (C) 2017 Red Hat Inc.
#
# Author: Peng Liu <pliu@redhat.com>
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

describe 'neutron::services::l2gw' do
  let :pre_condition do
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron': }"
  end

  let :default_params do
    { :package_ensure               => 'present',
      :purge_config                 => false,
    }
  end

  let :params do
    { :default_interface_name       => 'foo'}
  end

  shared_examples 'neutron l2gw service plugin' do
    context 'with default params' do
      let :p do
        default_params.merge(params)
      end

      it 'passes purge to resource' do
        should contain_resources('neutron_l2gw_service_config').with({
          :purge => false
        })
      end

      it 'should contain python-networking-l2gw package' do
          should contain_package('python-networking-l2gw').with({ :ensure => 'present' })
      end

      it 'services_provider with default parameter' do
        should contain_neutron_l2gw_service_config('service_providers/service_provider').with_value('<SERVICE DEFAULT>')
      end

      it 'configures l2gw_plugin.ini' do
        should contain_neutron_l2gw_service_config('DEFAULT/default_interface_name').with_value(p[:default_interface_name])
        should contain_neutron_l2gw_service_config('DEFAULT/default_device_name').with_value('<SERVICE DEFAULT>')
        should contain_neutron_l2gw_service_config('DEFAULT/quota_l2_gateway').with_value('<SERVICE DEFAULT>')
        should contain_neutron_l2gw_service_config('DEFAULT/periodic_monitoring_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_l2gw_service_config('service_providers/service_provider').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with multiple service providers' do
      before :each do
        params.merge!( :service_providers => ['provider1', 'provider2'],
                       :sync_db           => true )
      end

      it 'configures multiple service providers in l2gw_plugin.ini' do
        should contain_neutron_l2gw_service_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
      end

      it 'runs neutron-db-sync' do
        should contain_exec('l2gw-db-sync').with(
          :command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --subproject networking-l2gw upgrade head',
          :path        => '/usr/bin',
          :subscribe   => ['Anchor[neutron::install::end]',
                           'Anchor[neutron::config::end]',
                           'Anchor[neutron::dbsync::begin]'
                           ],
          :notify      => 'Anchor[neutron::dbsync::end]',
          :refreshonly => 'true',
        )
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :l2gw_agent_package_name => 'python3-networking-l2gw' }
        when 'RedHat'
          { :l2gw_agent_package_name => 'python3-networking-l2gw' }
        end
      end

      it_behaves_like 'neutron l2gw service plugin'
    end
  end
end
