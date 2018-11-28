#
# Copyright (C) 2016 Matthew J. Black
#
# Author: Matthew J. Black <mjblack@gmail.com>
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
# Unit tests for neutron::services::lbaas::haproxy class
#

require 'spec_helper'

describe 'neutron::services::lbaas::haproxy' do
  let :default_params do
    {
      :interface_driver        => '<SERVICE DEFAULT>',
      :periodic_interval       => '<SERVICE DEFAULT>',
      :loadbalancer_state_path => '<SERVICE DEFAULT>',
      :user_group              => '<SERVICE DEFAULT>',
      :send_gratuitous_arp     => '<SERVICE DEFAULT>',
      :jinja_config_template   => '<SERVICE DEFAULT>'}
  end

  shared_examples 'neutron::services::lbaas::haproxy' do
    context 'with default params' do
      let :params do
        default_params
      end

      it 'configures haproxy service plugin' do
        should contain_neutron_config('haproxy/interface_driver').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('haproxy/periodic_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('haproxy/loadbalancer_state_path').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('haproxy/user_group').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('haproxy/send_gratuitous_arp').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('haproxy/jinja_config_template').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when interface driver and gratuitous arp is set' do
      let :params do
        default_params.merge(
          {
            :interface_driver     => 'neutron.agent.linux.interface.OVSInterfaceDriver',
            :send_gratuitous_arp  => true,
          }
        )
      end

      it 'configures haproxy service plugin custom parameters' do
        should contain_neutron_config('haproxy/interface_driver').with_value('neutron.agent.linux.interface.OVSInterfaceDriver')
        should contain_neutron_config('haproxy/send_gratuitous_arp').with_value(true)
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

      it_behaves_like 'neutron::services::lbaas::haproxy'
    end
  end
end
