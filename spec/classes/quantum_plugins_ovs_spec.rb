require 'spec_helper'

describe 'quantum::plugins::ovs' do

  let :pre_condition do
    "class { 'quantum': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
   {
     :package_ensure       => 'present',
     :sql_connection       => 'sqlite:////var/lib/quantum/ovs.sqlite',
     :sql_max_retries      => 10,
     :sql_idle_timeout     => '3600',
     :reconnect_interval   => 2,
     :tenant_network_type  => 'vlan',
     :network_vlan_ranges  => 'physnet1:1000:2000',
     :tunnel_id_ranges     => '1:1000'
   }
  end

  let :params do
    {}
  end

  shared_examples_for 'quantum ovs plugin' do

    let :p do
      default_params.merge(params)
    end

    it 'should perform default configuration of' do
      should contain_quantum_plugin_ovs('OVS/network_vlan_ranges').\
        with_value(p[:network_vlan_ranges])
      should contain_quantum_plugin_ovs('DATABASE/sql_connection').with_value(p[:sql_connection])
      should contain_quantum_plugin_ovs('DATABASE/sql_max_retries').with_value(p[:sql_max_retries])
      should contain_quantum_plugin_ovs('DATABASE/sql_idle_timeout').with_value(p[:sql_idle_timeout])
      should contain_quantum_plugin_ovs('DATABASE/reconnect_interval').with_value(p[:reconnect_interval])
      should contain_quantum_plugin_ovs('OVS/tenant_network_type').with_value(p[:tenant_network_type])
      should_not contain_quantum_plugin_ovs('OVS/tunnel_id_ranges')
      should contain_quantum_plugin_ovs('OVS/network_vlan_ranges').with_value(p[:network_vlan_ranges])
      should contain_package('quantum-plugin-ovs').with(
        :name   => platform_params[:ovs_server_package],
        :ensure => p[:package_ensure]
      )
    end

    context 'with gre tunneling' do
      let :params do
        { :tenant_network_type => 'gre' }
      end

      it 'should perform gre network configuration' do
        should contain_quantum_plugin_ovs('OVS/network_vlan_ranges').with_ensure('absent')
        should contain_quantum_plugin_ovs('OVS/tenant_network_type').with_value(p[:tenant_network_type])
        should contain_quantum_plugin_ovs('OVS/tunnel_id_ranges').with_value(p[:tunnel_id_ranges])
      end
    end
    context 'with a flat network' do
      let :params do
        { :tenant_network_type => 'flat' }
      end
      it { should contain_quantum_plugin_ovs('OVS/network_vlan_ranges').with_value(p[:network_vlan_ranges]) }
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :ovs_server_package => 'quantum-plugin-openvswitch' }
    end

    it { should contain_class('quantum::plugins::ovs') }
    it_configures 'quantum ovs plugin'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :ovs_server_package => 'openstack-quantum-openvswitch' }
    end

    it { should contain_class('quantum::plugins::ovs') }
    it 'should perform redhat specific configuration' do
      should contain_file('/etc/quantum/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini',
        :require => 'Package[quantum-plugin-ovs]'
      )
    end
    it_configures 'quantum ovs plugin'
  end
end
