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
# Unit tests for neutron::plugins::ml2::arista::l3 class
#
require 'spec_helper'

describe 'neutron::plugins::ml2::arista::l3' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :secondary_l3_host => '<SERVICE DEFAULT>',
      :mlag_config       => '<SERVICE DEFAULT>',
      :l3_sync_interval  => '<SERVICE DEFAULT>',
      :use_vrf           => '<SERVICE DEFAULT>'
    }
  end

  let :params do
    { :primary_l3_host          => '127.0.0.1',
      :primary_l3_host_username => 'neutron',
      :primary_l3_host_password => 'passw0rd',
    }
  end

  shared_examples_for 'neutron plugin ml2 arista l3_arista' do
    before do
      params.merge!(default_params)
    end

    it 'configures ml2 arista l3_arista settings' do
      is_expected.to contain_neutron_plugin_ml2('l3_arista/primary_l3_host').with_value(params[:primary_l3_host])
      is_expected.to contain_neutron_plugin_ml2('l3_arista/primary_l3_host_username').with_value(params[:primary_l3_host_username])
      is_expected.to contain_neutron_plugin_ml2('l3_arista/primary_l3_host_password').with_value(params[:primary_l3_host_password])
    end
  end

  shared_examples_for 'ml2 l3_arista should fail when mlag is true and secondary is service default' do
    let :params do
      {}
    end

    before do
      params.merge!(default_params)
      params[:mlag_config] = true
    end

    it 'should fail when mlag is true and secondary l3 host is service default' do
      is_expected.to raise_error(Puppet::Error, /Must set secondary_l3_host when mlag_config is true./)
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

      it_configures 'neutron plugin ml2 arista l3_arista'
    end
  end
end
