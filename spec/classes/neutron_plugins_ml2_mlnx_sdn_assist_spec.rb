require 'spec_helper'

describe 'neutron::plugins::ml2::mellanox::mlnx_sdn_assist' do
  let :pre_condition do
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2'
     }"
  end

  let :default_params do
    {
      :sdn_url => '<SERVICE DEFAULT>',
    }
  end

  let :params do
    {
      :sdn_username => 'user',
      :sdn_password => 'password',
    }
  end

  shared_examples 'neutron plugin mellanox ml2 mlnx_sdn_assist' do
    before do
      params.merge!(default_params)
    end

    it 'configures sdn settings' do
      should contain_neutron_plugin_ml2('sdn/password').with_value(params[:sdn_password]).with_secret(true)
      should contain_neutron_plugin_ml2('sdn/username').with_value(params[:sdn_username])
      should contain_neutron_plugin_ml2('sdn/url').with_value(params[:sdn_url])
      should contain_neutron_plugin_ml2('sdn/sync_enabled').with_value('true')
      should contain_neutron_plugin_ml2('sdn/bind_normal_ports').with_value('false')
      should contain_neutron_plugin_ml2('sdn/bind_normal_ports_physnets').with_value([])
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin mellanox ml2 mlnx_sdn_assist'
    end
  end
end
