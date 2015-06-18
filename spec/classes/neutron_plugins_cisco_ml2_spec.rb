#
# Unit tests for neutron::plugins::ml2 class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::nexus' do

  let :pre_condition do
    "class { 'neutron::server': auth_password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :nexus_config          => nil
    }
  end

  let :params do
    {}
  end

  let :facts do
    { :operatingsystem         => 'default',
      :operatingsystemrelease  => 'default',
      :osfamily                => 'Debian'
    }
  end

  context 'fail when missing nexus_config' do
    it_raises 'a Puppet::Error', /No nexus config specified/
  end

  context 'when using cisco' do
    let (:nexus_config) do
      { 'cvf2leaff2' => {'username' => 'prad',
        "ssh_port" => 22,
        "password" => "password",
        "ip_address" => "172.18.117.28",
        "servers" => {
          "control02" => "portchannel:20",
          "control01" => "portchannel:10"
        }
      }
    }
    end

    before :each do
      params.merge!(:nexus_config => nexus_config )
    end

    it 'installs ncclient package' do
      is_expected.to contain_package('python-ncclient').with(
        :ensure => 'installed',
        :tag    => 'openstack'
      )
    end

  end

end


describe 'neutron::plugins::ml2::cisco::nexus1000v' do

  context 'verify default n1kv params in plugin.ini' do

    let :facts do
    { :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '7',
      :osfamily => 'RedHat'
    }
    end

    let :params do
    {
       :n1kv_vsm_ip                   => '9.0.0.1',
       :n1kv_vsm_username             => 'user1',
       :n1kv_vsm_password             => 'pasSw0rd',
       :default_policy_profile        => 'test-pp',
       :default_vlan_network_profile  => 'test-vlan-np',
       :default_vxlan_network_profile => 'test-vxlan-np',
       :poll_duration                 => '120',
       :http_pool_size                => '6',
       :http_timeout                  => '60',
       :sync_interval                 => '30',
       :max_vsm_retries               => '3',
       :restrict_policy_profiles      => 'False',
       :enable_vif_type_n1kv          => 'True',
    }
    end
    let :ml2_params do
    {
       :extension_drivers => 'cisco_n1kv_ext',
    }
    end
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
       is_expected.to contain_neutron_plugin_ml2('ml2/extension_drivers').with_value(ml2_params[:extension_drivers])
    end
  end
end
