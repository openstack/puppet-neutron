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
# Unit tests for neutron::agents::vpnaas class
#

require 'spec_helper'

describe 'neutron::agents::vpnaas' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {}
  end

  shared_examples 'neutron::agents::vpnaas' do
    context 'with defaults' do
      it { should contain_class('neutron::params') }

      it 'configures vpnaas_agent.ini' do
        should contain_neutron_vpnaas_agent_config('vpnagent/vpn_device_driver').with_value(
          'neutron_vpnaas.services.vpn.device_drivers.ipsec.OpenSwanDriver')
        should contain_neutron_vpnaas_agent_config('ipsec/ipsec_status_check_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_vpnaas_agent_config('DEFAULT/interface_driver').with_value(
          'neutron.agent.linux.interface.OVSInterfaceDriver')
      end

      it 'installs neutron vpnaas agent package' do
        should contain_package('neutron-vpnaas-agent').with(
          :ensure => 'present',
          :name   => platform_params[:vpnaas_agent_package],
          :tag    => ['openstack', 'neutron-package'],
        )
      end

      it 'installs openswan packages' do
        should contain_package('openswan').with(
          :ensure => 'present',
          :name   => platform_params[:openswan_package],
          :tag    => ['openstack', 'neutron-support-package'],
        )
      end
    end

    context 'with libreswan vpnaas driver' do
      let :params do
        {
          :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.libreswan_ipsec.LibreSwanDriver'
        }
      end

      it 'configures vpnaas_agent.ini' do
        should contain_neutron_vpnaas_agent_config('vpnagent/vpn_device_driver').with_value(
          'neutron_vpnaas.services.vpn.device_drivers.libreswan_ipsec.LibreSwanDriver')
      end

      it 'installs libreswan packages' do
        should contain_package('libreswan').with(
          :ensure => 'present',
          :name   => platform_params[:libreswan_package],
          :tag    => ['openstack', 'neutron-support-package'],
        )
      end
    end

    context 'with strongswan vpnaas driver' do
      let :params do
        {
          :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.strongswan_ipsec.StrongSwanDriver'
        }
      end

      it 'configures vpnaas_agent.ini' do
        should contain_neutron_vpnaas_agent_config('vpnagent/vpn_device_driver').with_value(
          'neutron_vpnaas.services.vpn.device_drivers.strongswan_ipsec.StrongSwanDriver')
      end

      it 'installs strongswan packages' do
        should contain_package('strongswan').with(
          :ensure => 'present',
          :name   => platform_params[:strongswan_package],
          :tag    => ['openstack', 'neutron-support-package'],
        )
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

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          {
            :openswan_package     => 'strongswan',
            :libreswan_package    => 'libreswan',
            :strongswan_package   => 'strongswan',
            :vpnaas_agent_package => 'python3-neutron-vpnaas'
          }
        when 'RedHat'
          {
            :openswan_package     => 'libreswan',
            :libreswan_package    => 'libreswan',
            :strongswan_package   => 'strongswan',
            :vpnaas_agent_package => 'openstack-neutron-vpnaas'
          }
        end
      end

      it_behaves_like 'neutron::agents::vpnaas'
    end
  end
end
