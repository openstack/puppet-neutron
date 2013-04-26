require 'spec_helper'

describe 'quantum::agents::ovs' do

  let :pre_condition do
    "class { 'quantum': rabbit_password => 'passw0rd' }\n" +
    "class { 'quantum::plugins::ovs': }"
  end

  let :default_params do
    { :package_ensure       => 'present',
      :enabled              => true,
      :bridge_uplinks       => [],
      :bridge_mappings      => [],
      :integration_bridge   => 'br-int',
      :enable_tunneling     => false,
      :local_ip             => false,
      :tunnel_bridge        => 'br-tun',
      :polling_interval     => 2,
      :root_helper          => 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf' }
  end

  let :params do
    {}
  end

  shared_examples_for 'quantum plugin ovs agent' do
    let :p do
      default_params.merge(params)
    end

    it { should include_class('quantum::params') }

    it 'configures ovs_quantum_plugin.ini' do
      should contain_quantum_plugin_ovs('AGENT/polling_interval').with_value(p[:polling_interval])
      should contain_quantum_plugin_ovs('AGENT/root_helper').with_value(p[:root_helper])
      should contain_quantum_plugin_ovs('OVS/integration_bridge').with_value(p[:integration_bridge])
    end

    it 'configures vs_bridge' do
      should contain_vs_bridge(p[:integration_bridge]).with(
        :ensure  => 'present',
        :require => 'Service[quantum-plugin-ovs-service]'
      )
    end

    it 'installs quantum ovs agent package' do
      if platform_params.has_key?(:ovs_agent_package)
        should contain_package('quantum-plugin-ovs-agent').with(
          :name   => platform_params[:ovs_agent_package],
          :ensure => p[:package_ensure]
        )
        should contain_package('quantum-plugin-ovs-agent').with_before(/Quantum_plugin_ovs\[.+\]/)
      else
        should contain_package('quantum-plugin-ovs').with_before(/Quantum_plugin_ovs\[.+\]/)
      end
    end

    it 'configures quantum ovs agent service' do
      should contain_service('quantum-plugin-ovs-service').with(
        :name    => platform_params[:ovs_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :require => 'Class[Quantum]'
      )
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :ovs_agent_package => 'quantum-plugin-openvswitch-agent',
        :ovs_agent_service => 'quantum-plugin-openvswitch-agent' }
    end

    it_configures 'quantum plugin ovs agent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :ovs_agent_service => 'quantum-openvswitch-agent' }
    end

    it_configures 'quantum plugin ovs agent'
  end
end
