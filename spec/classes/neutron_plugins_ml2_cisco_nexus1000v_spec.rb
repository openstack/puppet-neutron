require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::nexus1000v' do
  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2'
     }"
  end

  let :default_params do
    {
      :n1kv_vsm_ip                   => '10.10.10.10',
      :n1kv_vsm_username             => 'admin',
      :n1kv_vsm_password             => 'password',
      :default_policy_profile        => 'default-pp',
      :default_vlan_network_profile  => 'default-vlan-np',
      :default_vxlan_network_profile => 'default-vxlan-np',
      :poll_duration                 => '60',
      :http_pool_size                => '4',
      :http_timeout                  => '15',
      :sync_interval                 => '300',
      :max_vsm_retries               => '2',
      :restrict_policy_profiles      => 'False',
      :enable_vif_type_n1kv          => 'False',
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron cisco ml2 nexus1000v plugin' do

    before do
      params.merge!(default_params)
    end

    it { should contain_class('neutron::params') }

    it do
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/n1kv_vsm_ips').with_value(params[:n1kv_vsm_ip])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/username').with_value(params[:n1kv_vsm_username])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/password').with_value(params[:n1kv_vsm_password]).with_secret(true)
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/default_policy_profile').with_value(params[:default_policy_profile])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/default_vlan_network_profile').with_value(params[:default_vlan_network_profile])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/default_vxlan_network_profile').with_value(params[:default_vxlan_network_profile])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/poll_duration').with_value(params[:poll_duration])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/http_pool_size').with_value(params[:http_pool_size])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/http_timeout').with_value(params[:http_timeout])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/sync_interval').with_value(params[:sync_interval])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/max_vsm_retries').with_value(params[:max_vsm_retries])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/restrict_policy_profiles').with_value(params[:restrict_policy_profiles])
      should contain_neutron_plugin_ml2('ml2_cisco_n1kv/enable_vif_type_n1kv').with_value(params[:enable_vif_type_n1kv])
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'neutron cisco ml2 nexus1000v plugin'
      end
    end
  end
end
