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
      :firewall_driver     => 'quantum.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver' }
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
      should contain_quantum_plugin_ovs('OVS/integration_bridge').with_value(p[:integration_bridge])
      should contain_quantum_plugin_ovs('SECURITYGROUP/firewall_driver').\
        with_value(p[:firewall_driver])
      should contain_quantum_plugin_ovs('OVS/enable_tunneling').with_value(false)
      should contain_quantum_plugin_ovs('OVS/tunnel_bridge').with_ensure('absent')
      should contain_quantum_plugin_ovs('OVS/local_ip').with_ensure('absent')
    end

    it 'configures vs_bridge' do
      should contain_vs_bridge(p[:integration_bridge]).with(
        :ensure  => 'present',
        :before => 'Service[quantum-plugin-ovs-service]'
      )
      should_not contain_vs_brige(p[:integration_bridge])
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

    context 'when supplying a firewall driver' do
      before :each do
        params.merge!(:firewall_driver => false)
      end
      it 'should configure firewall driver' do
        should contain_quantum_plugin_ovs('SECURITYGROUP/firewall_driver').with_ensure('absent')
      end
    end

    context 'when supplying bridge mappings for provider networks' do
      before :each do
        params.merge!(:bridge_uplinks => ['br-ex:eth2'],:bridge_mappings => ['default:br-ex'])
      end

      it 'configures bridge mappings' do
        should contain_quantum_plugin_ovs('OVS/bridge_mappings')
      end

      it 'should configure bridge mappings' do
        should contain_quantum__plugins__ovs__bridge(params[:bridge_mappings].join(',')).with(
          :before => 'Service[quantum-plugin-ovs-service]'
        )
      end

      it 'should configure bridge uplinks' do
        should contain_quantum__plugins__ovs__port(params[:bridge_uplinks].join(',')).with(
          :before => 'Service[quantum-plugin-ovs-service]'
        )
      end
    end

    context 'when enabling tunneling' do
      context 'without local ip address' do
        before :each do
          params.merge!(:enable_tunneling => true)
        end
        it 'should fail' do
          expect do
            subject
          end.to raise_error(Puppet::Error, /Local ip for ovs agent must be set when tunneling is enabled/)
        end
      end
      context 'with default params' do
        before :each do
          params.merge!(:enable_tunneling => true, :local_ip => '127.0.0.1' )
        end
        it 'should configure ovs for tunneling' do
          should contain_quantum_plugin_ovs('OVS/enable_tunneling').with_value(true)
          should contain_quantum_plugin_ovs('OVS/tunnel_bridge').with_value(default_params[:tunnel_bridge])
          should contain_quantum_plugin_ovs('OVS/local_ip').with_value('127.0.0.1')
          should contain_vs_bridge(default_params[:tunnel_bridge]).with(
            :ensure  => 'present',
            :before => 'Service[quantum-plugin-ovs-service]'
          )
        end
      end
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
      { :ovs_cleanup_service => 'quantum-ovs-cleanup',
        :ovs_agent_service   => 'quantum-openvswitch-agent' }
    end

    it_configures 'quantum plugin ovs agent'
    it 'configures quantum ovs cleanup service' do
      should contain_service('ovs-cleanup-service').with(
        :name    => platform_params[:ovs_cleanup_service],
        :enable  => true,
        :ensure  => 'running'
      )
      should contain_package('quantum-plugin-ovs').with_before(/Service\[ovs-cleanup-service\]/)
    end

  end
end
