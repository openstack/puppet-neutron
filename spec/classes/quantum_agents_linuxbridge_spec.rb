require 'spec_helper'

describe 'quantum::agents::linuxbridge' do

  let :pre_condition do
    "class { 'quantum': rabbit_password => 'passw0rd' }"
  end

  let :params do
    { :physical_interface_mappings => 'physnet:eth0',
      :firewall_driver             => 'quantum.agent.linux.iptables_firewall.IptablesFirewallDriver',
      :package_ensure              => 'present',
      :enable                      => true
    }
  end

  shared_examples_for 'quantum linuxbridge agent' do

    it { should include_class('quantum::params') }

    it 'installs quantum linuxbridge agent package' do
      should contain_package('quantum-plugin-linuxbridge-agent').with(
        :ensure => params[:package_ensure],
        :name   => platform_params[:linuxbridge_agent_package]
      )
    end

    it 'configures quantum linuxbridge agent service' do
      should contain_service('quantum-plugin-linuxbridge-service').with(
        :ensure  => 'running',
        :name    => platform_params[:linuxbridge_agent_service],
        :enable  => params[:enable],
        :require => 'Package[quantum-plugin-linuxbridge-agent]'
      )
    end

    it 'configures linuxbridge_conf.ini' do
      should contain_quantum_plugin_linuxbridge('LINUX_BRIDGE/physical_interface_mappings').with(
        :value => params[:physical_interface_mappings]
      )
      should contain_quantum_plugin_linuxbridge('SECURITYGROUP/firewall_driver').with(
        :value => params[:firewall_driver]
      )
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :linuxbridge_agent_package => 'quantum-plugin-linuxbridge-agent',
        :linuxbridge_agent_service => 'quantum-plugin-linuxbridge-agent' }
    end

    it_configures 'quantum linuxbridge agent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :linuxbridge_agent_package => 'openstack-quantum-linuxbridge',
        :linuxbridge_agent_service => 'quantum-linuxbridge-agent' }
    end

    it_configures 'quantum linuxbridge agent'
  end
end
