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
# Unit tests for neutron::plugins::ml2::arista class
#
require 'spec_helper'

describe 'neutron::plugins::ml2::arista' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :region_name   => '<SERVICE DEFAULT>',
      :sync_interval => '<SERVICE DEFAULT>',
      :use_fqdn      => '<SERVICE DEFAULT>'
    }
  end

  let :params do
    { :eapi_host     => '127.0.0.1',
      :eapi_username => 'neutron',
      :eapi_password => 'passw0rd'
    }
  end

  shared_examples_for 'neutron plugin ml2 arista' do
    before do
      params.merge!(default_params)
    end

    it 'configures ml2 arista settings' do
      is_expected.to contain_neutron_plugin_ml2('ml2_arista/eapi_host').with_value(params[:eapi_host])
      is_expected.to contain_neutron_plugin_ml2('ml2_arista/eapi_username').with_value(params[:eapi_username])
      is_expected.to contain_neutron_plugin_ml2('ml2_arista/eapi_password').with_value(params[:eapi_password])
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|

    context "on #{os}" do
      let(:facts) do
        facts.merge!(OSDefaults.get_facts({
        }))
      end

      it_configures 'neutron plugin ml2 arista'
    end
  end
end
