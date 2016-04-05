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
    { :interface_driver        => '<SERVICE_DEFAULT>',
      :periodic_interval       => '<SERVICE_DEFAULT>',
      :loadbalancer_state_path => '<SERVICE_DEFAULT>',
      :user_group              => '<SERVICE_DEFAULT>',
      :send_gratuitous_arp     => '<SERVICE_DEFAULT>',
      :jinja_config_template   => '<SERVICE_DEFAULT>'}
  end

  context 'with default params' do
    let :params do
      default_params
    end

    it 'configures haproxy service plugin' do
      is_expected.to contain_neutron_config('haproxy/interface_driver').with_value('<SERVICE_DEFAULT>')
      is_expected.to contain_neutron_config('haproxy/periodic_interval').with_value('<SERVICE_DEFAULT>')
      is_expected.to contain_neutron_config('haproxy/loadbalancer_state_path').with_value('<SERVICE_DEFAULT>')
      is_expected.to contain_neutron_config('haproxy/user_group').with_value('<SERVICE_DEFAULT>')
      is_expected.to contain_neutron_config('haproxy/send_gratuitous_arp').with_value('<SERVICE_DEFAULT>')
      is_expected.to contain_neutron_config('haproxy/jinja_config_template').with_value('<SERVICE_DEFAULT>')
    end
  end

  context 'when interface driver and gratuitous arp is set' do
    let :params do
      default_params.merge(
        { :interface_driver     => 'neutron.agent.linux.interface.OVSInterfaceDriver',
          :send_gratuitous_arp  => true,
        }
      )
    end

    it 'configures haproxy service plugin custom parameters' do
      is_expected.to contain_neutron_config('haproxy/interface_driver').with_value('neutron.agent.linux.interface.OVSInterfaceDriver')
      is_expected.to contain_neutron_config('haproxy/send_gratuitous_arp').with_value(true)
    end
  end
end
