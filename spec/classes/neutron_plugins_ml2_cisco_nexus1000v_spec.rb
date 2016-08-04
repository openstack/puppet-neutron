#
# Unit tests for neutron::plugins::ml2::cisco::nexus1000v class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::nexus1000v' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :n1kv_vsm_ip => '10.10.10.10',
      :n1kv_vsm_username => 'admin',
      :n1kv_vsm_password => 'password',
      :default_policy_profile => 'default-pp',
      :default_vlan_network_profile => 'default-vlan-np',
      :default_vxlan_network_profile => 'default-vxlan-np',
      :poll_duration => '60',
      :http_pool_size => '4',
      :http_timeout => '15',
      :sync_interval => '300',
      :max_vsm_retries => '2',
      :restrict_policy_profiles => 'False',
      :enable_vif_type_n1kv => 'False',
    }
  end

  let :params do
    {}
  end

  let :test_facts do
    { :operatingsystem         => 'default',
      :operatingsystemrelease  => 'default',
      :concat_basedir          => '/',
    }
  end

  shared_examples_for 'neutron cisco ml2 nexus1000v plugin' do

    before do
      params.merge!(default_params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it do
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/n1kv_vsm_ips').with_value(params[:n1kv_vsm_ip])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/username').with_value(params[:n1kv_vsm_username])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/password').with_value(params[:n1kv_vsm_password])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/default_policy_profile').with_value(params[:default_policy_profile])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/default_vlan_network_profile').with_value(params[:default_vlan_network_profile])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/default_vxlan_network_profile').with_value(params[:default_vxlan_network_profile])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/poll_duration').with_value(params[:poll_duration])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/http_pool_size').with_value(params[:http_pool_size])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/http_timeout').with_value(params[:http_timeout])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/sync_interval').with_value(params[:sync_interval])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/max_vsm_retries').with_value(params[:max_vsm_retries])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/restrict_policy_profiles').with_value(params[:restrict_policy_profiles])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_n1kv/enable_vif_type_n1kv').with_value(params[:enable_vif_type_n1kv])
    end

  end

  begin
    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily => 'RedHat',
           :operatingsystemrelease => '7',
        }))
      end

      it_configures 'neutron cisco ml2 nexus1000v plugin'
    end
  end
end
