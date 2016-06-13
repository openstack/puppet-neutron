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
      rabbit_password => 'passw0rd',
      service_plugins => ['neutron.services.metering.metering_plugin.MeteringPlugin'] }"
  end

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present',
      :enabled          => true,
      :debug            => false,
      :interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :driver           => 'neutron.services.metering.drivers.noop.noop_driver.NoopMeteringDriver',
      :purge_config     => false,
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron metering agent' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_metering_agent_config').with({
        :purge => false
      })
    end

    it 'configures metering_agent.ini' do
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/debug').with_value(p[:debug]);
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/driver').with_value(p[:driver]);
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/measure_interval').with_value('<SERVICE DEFAULT>');
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/report_interval').with_value('<SERVICE DEFAULT>');
    end

    it 'installs neutron metering agent package' do
      if platform_params.has_key?(:metering_agent_package)
        is_expected.to contain_package('neutron-metering-agent').with(
          :name   => platform_params[:metering_agent_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        is_expected.to contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        is_expected.to contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    it 'configures neutron metering agent service' do
      is_expected.to contain_service('neutron-metering-service').with(
        :name    => platform_params[:metering_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      is_expected.to contain_service('neutron-metering-service').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('neutron-metering-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        is_expected.to contain_service('neutron-metering-service').without_ensure
      end
    end

    context 'with non-default driver' do
      before :each do
        params.merge!(:driver => 'neutron.services.metering.drivers.iptables.iptables_driver.IptablesMeteringDriver')
      end
      it 'should properly set driver option' do
        is_expected.to contain_neutron_metering_agent_config('DEFAULT/driver').with_value(p[:driver])
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian'
      }))
    end

    let :platform_params do
      { :metering_agent_package => 'neutron-metering-agent',
        :metering_agent_service => 'neutron-metering-agent' }
    end

    it_configures 'neutron metering agent'
    it 'configures subscription to neutron-metering-agent package' do
      is_expected.to contain_service('neutron-metering-service').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('neutron-metering-service').that_notifies('Anchor[neutron::service::end]')
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :platform_params do
      { :metering_agent_package => 'openstack-neutron-metering-agent',
        :metering_agent_service => 'neutron-metering-agent' }
    end

    it_configures 'neutron metering agent'
  end
end
