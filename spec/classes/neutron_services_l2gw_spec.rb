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
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
    { :package_ensure               => 'present',
      :purge_config                 => false,
    }
  end

  let :params do
    { :default_interface_name       => 'foo'}
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron l2gw service plugin' do
    let :p do
      default_params.merge(params)
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_l2gw_service_config').with({
        :purge => false
      })
    end

    it 'should contain python-networking-l2gw package' do
        is_expected.to contain_package('python-networking-l2gw').with({ :ensure => 'present' })
    end

    it 'services_provider with default parameter' do
      is_expected.to contain_neutron_l2gw_service_config('service_providers/service_provider').with_value('<SERVICE DEFAULT>')
    end

    it 'configures l2gw_plugin.ini' do
      is_expected.to contain_neutron_l2gw_service_config('DEFAULT/default_interface_name').with_value(p[:default_interface_name])
      is_expected.to contain_neutron_l2gw_service_config('DEFAULT/default_device_name').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_service_config('DEFAULT/quota_l2_gateway').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_service_config('DEFAULT/periodic_monitoring_interval').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_service_config('service_providers/service_provider').with_value('<SERVICE DEFAULT>')

    end

    context 'with multiple service providers' do
      before :each do
        params.merge!(
          { :service_providers => ['provider1', 'provider2'] }
        )
      end

      it 'configures multiple service providers in l2gw_plugin.ini' do
        is_expected.to contain_neutron_l2gw_service_config(
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
        case facts[:osfamily]
        when 'RedHat'
          { :l2gw_agent_package_name => 'python2-networking-l2gw' }
        when 'Debian'
          { :l2gw_agent_package_name => 'python-networking-l2gw' }
        end
      end

      it_configures 'neutron l2gw service plugin'
    end
  end

end