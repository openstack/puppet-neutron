require 'spec_helper'

describe 'quantum::plugins::linuxbridge' do

  let :pre_condition do
    "class { 'quantum': rabbit_password => 'passw0rd' }"
  end

  let :params do
    { :sql_connection      => 'mysql://user:pass@db/db',
      :network_vlan_ranges => 'physnet0:100:109',
      :tenant_network_type => 'vlan',
      :package_ensure      => 'installed'
    }
  end

  shared_examples_for 'quantum linuxbridge plugin' do

    it { should include_class('quantum::params') }

    it 'installs quantum linuxbridge plugin package' do
      should contain_package('quantum-plugin-linuxbridge').with(
        :ensure => params[:package_ensure],
        :name   => platform_params[:linuxbridge_plugin_package]
      )
    end

    it 'configures linuxbridge_conf.ini' do
      should contain_quantum_plugin_linuxbridge('DATABASE/sql_connection').with(
        :value => params[:sql_connection]
      )
      should contain_quantum_plugin_linuxbridge('VLANS/tenant_network_type').with(
        :value => params[:tenant_network_type]
      )
      should contain_quantum_plugin_linuxbridge('VLANS/network_vlan_ranges').with(
        :value => params[:network_vlan_ranges]
      )
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :linuxbridge_plugin_package => 'quantum-plugin-linuxbridge' }
    end

    it_configures 'quantum linuxbridge plugin'
    it 'configures /etc/default/quantum-server' do
      should contain_file_line('/etc/default/quantum-server:QUANTUM_PLUGIN_CONFIG').with(
        :line => 'QUANTUM_PLUGIN_CONFIG=/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini'
      )
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :linuxbridge_plugin_package => 'openstack-quantum-linuxbridge' }
    end

    it_configures 'quantum linuxbridge plugin'
  end
end
