# Copyright (C) 2017 Red Hat Inc.
#
# Author: Peng Liu <pliu@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'neutron::agents::l2gw' do

  let :default_params do
    { :package_ensure                   => 'present',
      :purge_config                     => false,
      :enabled                          => true,
      :manage_service                   => true,
      :debug                            => false,
      :enable_manager                   => false,
      :manager_table_listening_port     => '6632',
      :socket_timeout                   => '30',
    }
  end

  let :params do
    {}
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end
  shared_examples_for 'neutron l2 gateway agent' do
    let :p do
      default_params.merge(params)
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_l2gw_agent_config').with({
        :purge => false
      })
    end

    it 'installs l2gw agent package' do
      is_expected.to contain_package('neutron-l2gw-agent').with(
        :ensure => p[:package_ensure],
        :name   => platform_params[:l2gw_agent_package_name],
      )
    end

    it 'configures l2gw_plugin.ini' do
      is_expected.to contain_neutron_l2gw_agent_config('DEFAULT/debug').with_value(p[:debug])
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/enable_manager').with_value(p[:enable_manager])
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/manager_table_listening_port').with_value(p[:manager_table_listening_port])
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/l2_gw_agent_priv_key_base_path').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/l2_gw_agent_cert_base_path').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/l2_gw_agent_ca_cert_base_path').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/periodic_interval').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/max_connection_retries').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/socket_timeout').with_value(p[:socket_timeout])
      is_expected.to contain_neutron_l2gw_agent_config('ovsdb/ovsdb_hosts').with_value('<SERVICE DEFAULT>')
    end

    it 'l2 agent service running' do
      is_expected.to contain_service('neutron-l2gw-agent').with_ensure('running')
    end

    context 'with multiple ovsdb_hosts' do
      before :each do
        params.merge!(
          { :ovsdb_hosts => ['host1', 'host2'] }
        )
      end

      it 'configures multiple ovsdb_hosts in l2gateway_agent.ini' do
        is_expected.to contain_neutron_l2gw_agent_config(
          'ovsdb/ovsdb_hosts'
        ).with_value(p[:ovsdb_hosts].join(','))
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'RedHat'
          { :l2gw_agent_package_name => 'openstack-neutron-l2gw-agent' }
        when 'Debian'
          { :l2gw_agent_package_name => 'neutron-l2gw-agent' }
        end
      end

      it_configures 'neutron l2 gateway agent'
    end
  end
end
