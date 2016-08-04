#
# Unit tests for neutron::plugins::ml2::cisco::nexus class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::nexus' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :nexus_config => {
        'cvf2leaff2' => {
          'username' => 'prad',
          "ssh_port" => 22,
          "password" => "password",
          "ip_address" => "172.18.117.28",
          "nve_src_intf" => 1,
          "physnet" => "physnet1",
          "servers" => {
            "control02" => {"ports" => "portchannel:20"},
            "control01" => {"ports" => "portchannel:10"}
          }
        }
      },
      :managed_physical_network  => 'physnet1',
      :vlan_name_prefix          => 'q-',
      :svi_round_robin           => false,
      :provider_vlan_name_prefix => 'p-',
      :persistent_switch_config  => false,
      :switch_heartbeat_time     => 0,
      :switch_replay_count       => 3,
      :provider_vlan_auto_create => true,
      :provider_vlan_auto_trunk  => true,
      :vxlan_global_config       => true,
      :host_key_checks           => false
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

  shared_examples_for 'neutron cisco ml2 nexus plugin' do

    before do
      params.merge!(default_params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it do
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/managed_physical_network').with_value(params[:managed_physical_network])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/vlan_name_prefix').with_value(params[:vlan_name_prefix])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/svi_round_robin').with_value(params[:svi_round_robin])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/provider_vlan_name_prefix').with_value(params[:provider_vlan_name_prefix])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/persistent_switch_config').with_value(params[:persistent_switch_config])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/switch_heartbeat_time').with_value(params[:switch_heartbeat_time])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/switch_replay_count').with_value(params[:switch_replay_count])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/provider_vlan_auto_create').with_value(params[:provider_vlan_auto_create])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/provider_vlan_auto_trunk').with_value(params[:provider_vlan_auto_trunk])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/vxlan_global_config').with_value(params[:vxlan_global_config])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco/host_key_checks').with_value(params[:host_key_checks])
    end

    it {
      # Stored as an array of arrays with the first element consisting of the name and
      # the second element consisting of the config hash
      params[:nexus_config].each do |switch_config|
        is_expected.to contain_neutron__plugins__ml2__cisco__nexus_creds(switch_config.first)
      end
    }

  end

  begin
    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily               => 'RedHat',
           :operatingsystemrelease => '7'
        }))
      end

      let :platform_params do
        { :cisco_ml2_config_file => '/etc/neutron/conf.d/neutron-server/ml2_mech_cisco_nexus.conf' }
      end

      it_configures 'neutron cisco ml2 nexus plugin'
    end
  end
end
