require 'spec_helper'

describe 'neutron::plugins::ovs' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
   {
     :package_ensure       => 'present',
     :tunnel_id_ranges     => '1:1000',
     :network_vlan_ranges  => 'physnet1:1000:2000'
   }
  end

  let :params do
    { }
  end

  shared_examples_for 'neutron ovs plugin' do
    before do
      params.merge!(default_params) { |key, v1, v2| v1 }
    end

    let :params do
      { :tenant_network_type => 'vlan' }
    end

    it 'should create plugin symbolic link' do
      is_expected.to contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini',
        :require => 'Package[neutron-plugin-ovs]'
      )
    end

    it 'should perform default configuration of' do
      is_expected.to contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
      is_expected.to contain_package('neutron-plugin-ovs').with(
        :name   => platform_params[:ovs_server_package],
        :ensure => params[:package_ensure],
        :tag    => 'openstack'
      )
      is_expected.not_to contain_class('vswitch::ovs')
    end

    context 'with vlan mode' do
      let :params do
        { :tenant_network_type => 'vlan' }
      end

      it 'should perform vlan network configuration' do
        is_expected.to contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
        is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges])
      end
    end

    context 'with gre tunneling' do
      let :params do
        { :tenant_network_type => 'gre', :tunnel_id_ranges => '1:1000'}
      end

      before do
        params.delete(:network_vlan_ranges)
      end

      it 'should perform gre network configuration' do
        is_expected.to contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
        is_expected.to contain_neutron_plugin_ovs('OVS/tunnel_id_ranges').with_value(params[:tunnel_id_ranges])
        is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_ensure('absent')
      end
    end

    context 'with gre tunneling and provider networks' do
      let :params do
        { :tenant_network_type => 'gre',
          :network_vlan_ranges => 'physnet1:1000:2000',
          :tunnel_id_ranges    => '1:1000'}
      end

      it 'should perform gre network configuration' do
        is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges])
        is_expected.to contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
        is_expected.to contain_neutron_plugin_ovs('OVS/tunnel_id_ranges').with_value(params[:tunnel_id_ranges])
      end
    end

    context 'with vxlan tunneling' do
      let :params do
        { :tenant_network_type => 'vxlan',
          :vxlan_udp_port      => '4789'}
      end

      before do
        params.delete(:network_vlan_ranges)
      end

      it 'should perform vxlan network configuration' do
        is_expected.to contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
        is_expected.to contain_neutron_plugin_ovs('OVS/vxlan_udp_port').with_value(params[:vxlan_udp_port])
        is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_ensure('absent')
      end
    end

    context 'with vxlan tunnelling using bad vxlan_udp_port' do
      let :params do
        { :tenant_network_type => 'vxlan',
          :vxlan_udp_port      => '1',}
      end

      it_raises 'a Puppet::Error', /vxlan udp port is invalid./
    end

    context 'with vxlan tunnelling using bad tunnel_id_ranges' do
      let :params do
        { :tenant_network_type => 'vxlan',
          :tunnel_id_ranges    => '100:9',}
      end

      it_raises 'a Puppet::Error', /tunnel id ranges are invalid./
    end

    context 'with vxlan tunneling and provider networks using bad network_vlan_ranges' do
      let :params do
        { :tenant_network_type => 'vxlan',
          :network_vlan_ranges => 'physnet1:200:1'}
      end

      it_raises 'a Puppet::Error', /network vlan ranges are invalid./
    end

    context 'with vxlan tunneling using bad multiple network_vlan_ranges' do
      let :params do
        { :tenant_network_type => 'vxlan',
          :network_vlan_ranges => ['physnet1:0:100', 'physnet2:1000:1']}
      end

      it_raises 'a Puppet::Error', /network vlan ranges are invalid/
    end

    context 'with vxlan tunneling and provider networks' do
      let :params do
        { :tenant_network_type => 'vxlan',
          :network_vlan_ranges => 'physnet1:1000:2000'}
      end

      it 'should perform vxlan network configuration' do
        is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges])
        is_expected.to contain_neutron_plugin_ovs('OVS/tenant_network_type').with_value(params[:tenant_network_type])
      end
    end

    context 'with a flat network' do
      let :params do
        { :tenant_network_type => 'flat'}
      end
      it { is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges]) }
    end

    context 'with comma separated vlan ranges' do
      let :params do
        { :network_vlan_ranges => 'physint1:1000:2000,physext1:100:200' }
      end
      it { is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges]) }
    end

    context 'with vlan ranges in array' do
      let :params do
        { :network_vlan_ranges => ['physint1:1000:2000', 'physext1:100:200'] }
      end
      it { is_expected.to contain_neutron_plugin_ovs('OVS/network_vlan_ranges').with_value(params[:network_vlan_ranges].join(',')) }
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
      { :network_vlan_ranges => 'physnet1:1000:2000' }
    end

    let :platform_params do
      { :ovs_server_package => 'openstack-neutron-openvswitch' }
    end

    it_configures 'neutron ovs plugin'
  end
end
