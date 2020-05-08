#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
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
# Unit tests for neutron::services::fwaas class
#

require 'spec_helper'

describe 'neutron::services::fwaas' do
  let :pre_condition do
    "class { 'neutron': }
     include neutron::agents::l3"
  end

  let :params do
    {}
  end

  let :default_params do
    {
      :vpnaas_agent_package => false,
      :purge_config         => false,
    }
  end

  shared_examples 'neutron fwaas service plugin' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_fwaas_service_config').with({
        :purge => false
      })
    end

    it 'configures driver in fwaas_driver.ini' do
      should contain_neutron_fwaas_service_config('fwaas/driver').with_value('<SERVICE DEFAULT>')
      should contain_neutron_fwaas_service_config('fwaas/enabled').with_value('<SERVICE DEFAULT>')
      should contain_neutron_fwaas_service_config('fwaas/agent_version').with_value('<SERVICE DEFAULT>')
    end

    it 'configures driver in neutron.conf' do
      should contain_neutron_config('fwaas/driver').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('fwaas/enabled').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('fwaas/agent_version').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples 'neutron::services::fwaas on Ubuntu' do
    it 'installs neutron fwaas package' do
      should contain_package('neutron-fwaas').with(
        :ensure => 'present',
        :tag    => ['openstack', 'neutron-package'],
        :name   => platform_params[:fwaas_package_name],
      )
    end
  end

  shared_examples 'neutron::services::fwaas on Debian' do
    context 'without VPNaaS package' do
      it 'installs neutron fwaas package' do
        should contain_package('neutron-fwaas').with(
          :ensure => 'present',
          :tag    => ['openstack', 'neutron-package'],
          :name   => platform_params[:fwaas_package_name],
        )
      end
    end

    context 'with VPNaaS package' do
      before do
        params.merge!( :vpnaas_agent_package => true )
      end

      it 'installs neutron vpnaas agent package' do
        should contain_package('neutron-vpn-agent').with(
          :ensure => 'present',
          :name   => platform_params[:vpnaas_package_name],
          :tag    => ['openstack', 'neutron-package'],
        )
      end
    end
  end

  shared_examples 'neutron::services::fwaas on RedHat' do
    it 'installs neutron fwaas service package' do
      should contain_package('neutron-fwaas').with(
        :ensure => 'present',
        :name   => platform_params[:fwaas_package_name],
      )
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { 
            :fwaas_package_name   => 'python3-neutron-fwaas',
            :vpnaas_package_name  => 'python3-neutron-vpnaas'
          }
        when 'RedHat'
          {
            :fwaas_package_name => 'openstack-neutron-fwaas'
          }
        end
      end

      it_behaves_like 'neutron fwaas service plugin'

      case facts[:operatingsystem]
      when 'Debian'
        it_behaves_like 'neutron::services::fwaas on Debian'
      when 'Ubuntu'
        it_behaves_like 'neutron::services::fwaas on Ubuntu'
      end

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'neutron::services::fwaas on RedHat'
      end
    end
  end
end
