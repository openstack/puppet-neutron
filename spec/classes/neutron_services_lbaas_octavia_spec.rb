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
# Unit tests for neutron::services::lbaas::octavia class
#

require 'spec_helper'

describe 'neutron::services::lbaas::octavia' do

  let :default_params do
    { :base_url              => 'http://127.0.0.1:9876',
      :request_poll_interval => '<SERVICE_DEFAULT>',
      :request_poll_timeout  => '<SERVICE_DEFAULT>',
      :allocates_vip         => '<SERVICE_DEFAULT>'}
  end

  context 'with default params' do
    let :params do
      default_params
    end

    it 'configures octavia service plugin' do
      is_expected.to contain_neutron_config('octavia/base_url').with_value('http://127.0.0.1:9876')
      is_expected.to contain_neutron_config('octavia/request_poll_interval').with_value('<SERVICE_DEFAULT>')
      is_expected.to contain_neutron_config('octavia/request_poll_timeout').with_value('<SERVICE_DEFAULT>')
      is_expected.to contain_neutron_config('octavia/allocates_vip').with_value('<SERVICE_DEFAULT>')
    end
  end

  context 'when base_url is set' do
    let :params do
      default_params.merge(
        { :base_url              => 'http://octavia.example.org:9876',
          :request_poll_interval => '3',
          :request_poll_timeout  => '100',
          :allocates_vip         => 'false'
        }
      )
    end

    it 'configures octavia service plugin custom parameters' do
      is_expected.to contain_neutron_config('octavia/base_url').with_value('http://octavia.example.org:9876')
      is_expected.to contain_neutron_config('octavia/request_poll_interval').with_value('3')
      is_expected.to contain_neutron_config('octavia/request_poll_timeout').with_value('100')
      is_expected.to contain_neutron_config('octavia/allocates_vip').with_value('false')
    end
  end
end
