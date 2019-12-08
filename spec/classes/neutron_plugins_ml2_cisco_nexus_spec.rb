require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::nexus' do
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
      :nexus_config              => {
        'cvf2leaff2' => {
          'username'                => 'prad',
          "password"                => "password",
          "ip_address"              => "172.18.117.28",
          "nve_src_intf"            => 1,
          "physnet"                 => "physnet1",
          "vpc_pool"                => "",
          "intfcfg_portchannel"     => "",
          "https_verify"            => false,
          "https_local_certificate" => "",
          "servers"                 => {
            "control02" => {
              "hostname" => "control02",
              "ports"    => "portchannel:20"
            },
            "control01" => {
              "hostname" => "control01",
              "ports"    => "portchannel:10"
            }
          }
        }
      },
      :managed_physical_network  => 'physnet1',
      :switch_heartbeat_time     => 30,
      :provider_vlan_auto_create => true,
      :provider_vlan_auto_trunk  => true,
      :vxlan_global_config       => true
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron cisco ml2 nexus plugin' do
    before do
      params.merge!(default_params)
    end

    it { should contain_class('neutron::params') }

    it do
      should contain_neutron_plugin_ml2('ml2_cisco/managed_physical_network').with_value(params[:managed_physical_network])
      should contain_neutron_plugin_ml2('ml2_cisco/switch_heartbeat_time').with_value(params[:switch_heartbeat_time])
      should contain_neutron_plugin_ml2('ml2_cisco/provider_vlan_auto_create').with_value(params[:provider_vlan_auto_create])
      should contain_neutron_plugin_ml2('ml2_cisco/provider_vlan_auto_trunk').with_value(params[:provider_vlan_auto_trunk])
      should contain_neutron_plugin_ml2('ml2_cisco/vxlan_global_config').with_value(params[:vxlan_global_config])
    end

    it {
      # Stored as an array of arrays with the first element consisting of the name and
      # the second element consisting of the config hash
      params[:nexus_config].each do |switch_config|
        should contain_neutron__plugins__ml2__cisco__nexus_creds(switch_config.first)
      end
    }

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'RedHat'
          {
            :cisco_ml2_config_file => '/etc/neutron/conf.d/neutron-server/ml2_mech_cisco_nexus.conf'
          }
        end
      end

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'neutron cisco ml2 nexus plugin'
      end
    end
  end
end
