require 'spec_helper'

describe 'neutron::plugins::ovs' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
   {
     :package_ensure       => 'present',
     :sql_connection       => false,
     :sql_max_retries      => false,
     :sql_idle_timeout     => false,
     :reconnect_interval   => false,
     :tunnel_id_ranges     => '1:1000',
     :network_vlan_ranges  => 'physnet1:1000:2000'
   }
  end

  let :params do
    { }
  end

  shared_examples_for 'neutron ovs plugin' do
    before do
      params.merge!(default_params)
    end

    let :params do
      { :tenant_network_type => 'vlan' }
    end

    it 'should perform default configuration of' do
      should contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
      should contain_package('neutron-plugin-ovs').with(
        :name   => platform_params[:ovs_server_package],
        :ensure => params[:package_ensure]
      )
      should_not include_class('vswitch::ovs')
    end

    context 'with vlan mode' do
      let :params do
        { :tenant_network_type => 'vlan' }
      end

      it 'should perform vlan network configuration' do
        should contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
        should contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges])
      end
    end

    context 'with gre tunneling' do
      let :params do
        { :tenant_network_type => 'gre', :tunnel_id_ranges => '1:1000'}
      end

      before do
        params.delete('network_vlan_ranges')
      end

      it 'should perform gre network configuration' do
        should contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
        should contain_neutron_plugin_ovs('OVS/tunnel_id_ranges').with_value(params[:tunnel_id_ranges])
      end
    end

    context 'with gre tunneling and provider networks' do
      let :params do
        { :tenant_network_type => 'gre',
          :network_vlan_ranges => 'physnet1:1000:2000',
          :tunnel_id_ranges    => '1:1000'}
      end

      it 'should perform gre network configuration' do
        should contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges])
        should contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
        should contain_neutron_plugin_ovs('OVS/tunnel_id_ranges').with_value(params[:tunnel_id_ranges])
      end
    end

    context 'with a flat network' do
      let :params do
        { :tenant_network_type => 'flat'}
      end
      it { should contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges]) }
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :ovs_server_package => 'neutron-plugin-openvswitch' }
    end

    it_configures 'neutron ovs plugin'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :network_vlan_ranges => 'test' }
    end

    let :platform_params do
      { :ovs_server_package => 'openstack-neutron-openvswitch' }
    end

    it 'should perform redhat specific configuration' do
      should contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini',
        :require => 'Package[neutron-plugin-ovs]'
      )
    end

    it_configures 'neutron ovs plugin'
  end
end
