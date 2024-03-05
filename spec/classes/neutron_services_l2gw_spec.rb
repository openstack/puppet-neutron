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
  shared_examples 'neutron l2gw service plugin' do
    context 'with default params' do
      let :p do
        default_params.merge(params)
      end

      it 'should contain python-networking-l2gw package' do
        should contain_package('python-networking-l2gw').with(
          :ensure => 'present',
          :name   => platform_params[:l2gw_package_name],
          :tag    => ['openstack', 'neutron-package'],
        )
      end

      it 'configures l2gw_plugin.ini' do
        should contain_neutron_l2gw_service_config('DEFAULT/default_interface_name').with_value('<SERVICE DEFAULT>')
        should contain_neutron_l2gw_service_config('DEFAULT/default_device_name').with_value('<SERVICE DEFAULT>')
        should contain_neutron_l2gw_service_config('DEFAULT/quota_l2_gateway').with_value('<SERVICE DEFAULT>')
        should contain_neutron_l2gw_service_config('DEFAULT/periodic_monitoring_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_l2gw_service_config('service_providers/service_provider').with_value(
          'L2GW:l2gw:networking_l2gw.services.l2gateway.service_drivers.rpc_l2gw.L2gwRpcDriver:default'
        )
      end

      it 'does not run neutron-db-manage' do
        should_not contain_exec('l2gw-db-sync')
      end
    end

    context 'with parameters' do
      let :params do
        {
          :purge_config           => false,
          :default_interface_name => 'foo',
        }
      end

      it 'passes purge to resource' do
        should contain_resources('neutron_l2gw_service_config').with({
          :purge => false
        })
      end

      it 'configures l2gw_plugin.ini' do
        should contain_neutron_l2gw_service_config('DEFAULT/default_interface_name').with_value('foo')
      end
    end

    context 'with db sync enabled' do
      let :params do
        {
          :sync_db => true
        }
      end

      it 'runs neutron-db-manage' do
        should contain_exec('l2gw-db-sync').with(
          :command     => 'neutron-db-manage --subproject networking-l2gw upgrade head',
          :path        => '/usr/bin',
          :user        => 'neutron',
          :subscribe   => ['Anchor[neutron::install::end]',
                           'Anchor[neutron::config::end]',
                           'Anchor[neutron::dbsync::begin]'
                           ],
          :notify      => 'Anchor[neutron::dbsync::end]',
          :refreshonly => 'true',
        )
      end
    end

    context 'with multiple service providers' do
      let :params do
        {
          :service_providers => ['provider1', 'provider2']
        }
      end

      it 'configures multiple service providers in l2gw_plugin.ini' do
        should contain_neutron_l2gw_service_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
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
        case facts[:os]['family']
        when 'Debian'
          { :l2gw_package_name => 'python3-networking-l2gw' }
        when 'RedHat'
          { :l2gw_package_name => 'python3-networking-l2gw' }
        end
      end

      it_behaves_like 'neutron l2gw service plugin'
    end
  end
end
