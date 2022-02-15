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
# Unit tests for neutron::plugins::metering class
#

require 'spec_helper'

describe 'neutron::agents::metering' do
  let :pre_condition do
    "class { 'neutron':
      service_plugins => ['neutron.services.metering.metering_plugin.MeteringPlugin']
     }"
  end

  let :params do
    {}
  end

  let :default_params do
    {
      :package_ensure   => 'present',
      :enabled          => true,
      :interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :driver           => 'neutron.services.metering.drivers.noop.noop_driver.NoopMeteringDriver',
      :purge_config     => false,
    }
  end

  shared_examples 'neutron metering agent' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'passes purge to resource' do
      should contain_resources('neutron_metering_agent_config').with({
        :purge => false
      })
    end

    it 'configures metering_agent.ini' do
      should contain_neutron_metering_agent_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>');
      should contain_neutron_metering_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      should contain_neutron_metering_agent_config('DEFAULT/driver').with_value(p[:driver]);
      should contain_neutron_metering_agent_config('DEFAULT/measure_interval').with_value('<SERVICE DEFAULT>');
      should contain_neutron_metering_agent_config('DEFAULT/report_interval').with_value('<SERVICE DEFAULT>');
      should contain_neutron_metering_agent_config('DEFAULT/rpc_response_max_timeout').with_value('<SERVICE DEFAULT>');
    end

    it 'installs neutron metering agent package' do
      if platform_params.has_key?(:metering_agent_package)
        should contain_package('neutron-metering-agent').with(
          :name   => platform_params[:metering_agent_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        should contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    it 'configures neutron metering agent service' do
      should contain_service('neutron-metering-service').with(
        :name    => platform_params[:metering_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('neutron-metering-service').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-metering-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end

      it 'should not manage the service' do
        should_not contain_service('neutron-metering-service')
      end
    end

    context 'with non-default driver' do
      before :each do
        params.merge!(:driver => 'neutron.services.metering.drivers.iptables.iptables_driver.IptablesMeteringDriver')
      end

      it 'should properly set driver option' do
        should contain_neutron_metering_agent_config('DEFAULT/driver').with_value(p[:driver])
      end
    end
  end

  shared_examples 'neutron metering agent on Debian' do
    it 'configures subscription to neutron-metering-agent package' do
      should contain_service('neutron-metering-service').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-metering-service').that_notifies('Anchor[neutron::service::end]')
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
            :metering_agent_package => 'neutron-metering-agent',
            :metering_agent_service => 'neutron-metering-agent'
          }
        when 'RedHat'
          {
            :metering_agent_package => 'openstack-neutron-metering-agent',
            :metering_agent_service => 'neutron-metering-agent'
          }
        end
      end

      it_behaves_like 'neutron metering agent'

      if facts[:osfamily] == 'Debian'
        it_behaves_like 'neutron metering agent on Debian'
      end
    end
  end
end
