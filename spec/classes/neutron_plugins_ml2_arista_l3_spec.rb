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
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2' }"
  end

  let :default_params do
    {
      :secondary_l3_host => '<SERVICE DEFAULT>',
      :mlag_config       => '<SERVICE DEFAULT>',
      :l3_sync_interval  => '<SERVICE DEFAULT>',
      :conn_timeout      => '<SERVICE DEFAULT>',
      :use_vrf           => '<SERVICE DEFAULT>'
    }
  end

  let :params do
    { :primary_l3_host          => '127.0.0.1',
      :primary_l3_host_username => 'neutron',
      :primary_l3_host_password => 'passw0rd',
    }
  end

  shared_examples 'neutron plugin ml2 arista l3_arista' do
    let :p do
      default_params.merge(params)
    end

    it 'configures ml2 arista l3_arista settings' do
      should contain_neutron_plugin_ml2('l3_arista/primary_l3_host').with_value(p[:primary_l3_host])
      should contain_neutron_plugin_ml2('l3_arista/primary_l3_host_username').with_value(p[:primary_l3_host_username])
      should contain_neutron_plugin_ml2('l3_arista/primary_l3_host_password').with_value(p[:primary_l3_host_password]).with_secret(true)
      should contain_neutron_plugin_ml2('l3_arista/secondary_l3_host').with_value(p[:secondary_l3_host])
      should contain_neutron_plugin_ml2('l3_arista/mlag_config').with_value(p[:mlag_config])
      should contain_neutron_plugin_ml2('l3_arista/l3_sync_interval').with_value(p[:l3_sync_interval])
      should contain_neutron_plugin_ml2('l3_arista/conn_timeout').with_value(p[:conn_timeout])
      should contain_neutron_plugin_ml2('l3_arista/use_vrf').with_value(p[:use_vrf])
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|

    context "on #{os}" do
      let(:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin ml2 arista l3_arista'
    end
  end
end
