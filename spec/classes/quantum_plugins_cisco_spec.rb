require 'spec_helper'

describe 'quantum::plugins::cisco' do

  let :pre_condition do
    "class { 'quantum::server': auth_password => 'password'}"
  end

  let :params do
    { :keystone_username => 'quantum',
      :keystone_password => 'quantum_pass',
      :keystone_auth_url => 'http://127.0.0.1:35357/v2.0/',
      :keystone_tenant   => 'tenant',

      :database_name     => 'quantum',
      :database_pass     => 'dbpass',
      :database_host     => 'localhost',
      :database_user     => 'quantum'}
  end

  let :params_default do
    {
      :vswitch_plugin    => 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
      :vlan_start        => '100',
      :vlan_end          => '3000',
      :vlan_name_prefix  => 'q-',
      :model_class       => 'quantum.plugins.cisco.models.virt_phy_sw_v2.VirtualPhysicalSwitchModelV2',
      :max_ports         => '100',
      :max_port_profiles => '65568',
      :max_networks      => '65568',
      :manager_class     => 'quantum.plugins.cisco.segmentation.l2network_vlan_mgr_v2.L2NetworkVLANMgr',
      :package_ensure    => 'present'
    }
  end

  shared_examples_for 'default cisco plugin' do

    before do
      params.merge!(params_default)
    end

    it { should include_class('quantum::params') }

    it 'installs quantum cisco plugin package' do
      should contain_package('quantum-plugin-cisco').with(
        :ensure => params[:package_ensure],
        :name   => platform_params[:cisco_plugin_package]
      )
    end

    it 'should have a plugin config folder' do
      should contain_file('/etc/quantum/plugins').with(
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'quantum',
        :mode   => '0640'
      )
    end

    it 'should have a cisco plugin config folder' do
      should contain_file('/etc/quantum/plugins/cisco').with(
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'quantum',
        :mode   => '0640'
      )
    end

    it 'should perform default l2 configuration' do
      should contain_quantum_plugin_cisco_l2network('VLANS/vlan_start').\
        with_value(params[:vlan_start])
      should contain_quantum_plugin_cisco_l2network('VLANS/vlan_end').\
        with_value(params[:vlan_end])
      should contain_quantum_plugin_cisco_l2network('VLANS/vlan_name_prefix').\
        with_value(params[:vlan_name_prefix])
      should contain_quantum_plugin_cisco_l2network('MODEL/model_class').\
        with_value(params[:model_class])
      should contain_quantum_plugin_cisco_l2network('PORTS/max_ports').\
        with_value(params[:max_ports])
      should contain_quantum_plugin_cisco_l2network('PORTPROFILES/max_port_profiles').\
        with_value(params[:max_port_profiles])
      should contain_quantum_plugin_cisco_l2network('NETWORKS/max_networks').\
        with_value(params[:max_networks])
      should contain_quantum_plugin_cisco_l2network('SEGMENTATION/manager_class').\
        with_value(params[:manager_class])
    end

    it 'should create a dummy inventory item' do
      should contain_quantum_plugin_cisco('INVENTORY/dummy').\
        with_value('dummy')
    end

    it 'should configure the db connection' do
      should contain_quantum_plugin_cisco_db_conn('DATABASE/name').\
        with_value(params[:database_name])
      should contain_quantum_plugin_cisco_db_conn('DATABASE/user').\
        with_value(params[:database_user])
      should contain_quantum_plugin_cisco_db_conn('DATABASE/pass').\
        with_value(params[:database_pass])
      should contain_quantum_plugin_cisco_db_conn('DATABASE/host').\
        with_value(params[:database_host])
    end

    it 'should configure the admin credentials' do
      should contain_quantum_plugin_cisco_credentials('keystone/username').\
        with_value(params[:keystone_username])
      should contain_quantum_plugin_cisco_credentials('keystone/password').\
        with_value(params[:keystone_password])
      should contain_quantum_plugin_cisco_credentials('keystone/auth_url').\
        with_value(params[:keystone_auth_url])
      should contain_quantum_plugin_cisco_credentials('keystone/tenant').\
        with_value(params[:keystone_tenant])
    end

    it 'should perform vswitch plugin configuration' do
      should contain_quantum_plugin_cisco('PLUGINS/vswitch_plugin').\
          with_value('quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2')
    end

    describe 'with nexus plugin' do
      before do
        params.merge!(:nexus_plugin => 'quantum.plugins.cisco.nexus.cisco_nexus_plugin_v2.NexusPlugin')
      end

      it 'should perform nexus plugin configuration' do
        should contain_quantum_plugin_cisco('PLUGINS/nexus_plugin').\
          with_value('quantum.plugins.cisco.nexus.cisco_nexus_plugin_v2.NexusPlugin')
      end
    end

  end
  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :cisco_plugin_package => 'quantum-plugin-cisco' }
    end

    it_configures 'default cisco plugin'

    describe 'with n1k plugin' do
      before do
        params.merge!(:vswitch_plugin => 'quantum.plugins.cisco.n1kv.n1kv_quantum_plugin.N1kvQuantumPluginV2')
      end
      it 'configures /etc/default/quantum-server' do
        should contain_file_line('/etc/default/quantum-server:QUANTUM_PLUGIN_CONFIG').with(
          :line => 'QUANTUM_PLUGIN_CONFIG=/etc/quantum/plugins/cisco/cisco_plugins.ini',
          :require => ['Package[quantum-server]', 'Package[quantum-plugin-cisco]']
        )
      end
    end
  end
end
