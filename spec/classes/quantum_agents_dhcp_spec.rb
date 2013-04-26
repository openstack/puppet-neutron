require 'spec_helper'

describe 'quantum::agents::dhcp' do

  let :pre_condition do
    "class { 'quantum': rabbit_password => 'passw0rd' }"
  end

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present',
      :enabled          => true,
      :debug            => false,
      :state_path       => '/var/lib/quantum',
      :resync_interval  => 30,
      :interface_driver => 'quantum.agent.linux.interface.OVSInterfaceDriver',
      :dhcp_driver      => 'quantum.agent.linux.dhcp.Dnsmasq',
      :use_namespaces   => true,
      :root_helper      => 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf' }
  end


  shared_examples_for 'quantum dhcp agent' do
    let :p do
      default_params.merge(params)
    end

    it { should include_class('quantum::params') }

    it_configures 'dnsmasq dhcp_driver'

    it 'configures dhcp_agent.ini' do
      should contain_quantum_dhcp_agent_config('DEFAULT/debug').with_value(p[:debug]);
      should contain_quantum_dhcp_agent_config('DEFAULT/state_path').with_value(p[:state_path]);
      should contain_quantum_dhcp_agent_config('DEFAULT/resync_interval').with_value(p[:resync_interval]);
      should contain_quantum_dhcp_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      should contain_quantum_dhcp_agent_config('DEFAULT/dhcp_driver').with_value(p[:dhcp_driver]);
      should contain_quantum_dhcp_agent_config('DEFAULT/use_namespaces').with_value(p[:use_namespaces]);
      should contain_quantum_dhcp_agent_config('DEFAULT/root_helper').with_value(p[:root_helper]);
    end

    it 'installs quantum dhcp agent package' do
      if platform_params.has_key?(:dhcp_agent_package)
        should contain_package('quantum-dhcp-agent').with(
          :name   => platform_params[:dhcp_agent_package],
          :ensure => p[:package_ensure]
        )
        should contain_package('quantum').with_before(/Package\[quantum-dhcp-agent\]/)
        should contain_package('quantum-dhcp-agent').with_before(/Quantum_dhcp_agent_config\[.+\]/)
        should contain_package('quantum-dhcp-agent').with_before(/Quantum_config\[.+\]/)
      else
        should contain_package('quantum').with_before(/Quantum_dhcp_agent_config\[.+\]/)
      end
    end

    it 'configures quantum dhcp agent service' do
      should contain_service('quantum-dhcp-service').with(
        :name    => platform_params[:dhcp_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :require => 'Class[Quantum]'
      )
    end
  end

  shared_examples_for 'dnsmasq dhcp_driver' do
    it 'installs dnsmasq packages' do
      if platform_params.has_key?(:dhcp_agent_package)
        should contain_package('dnsmasq').with_before('Package[quantum-dhcp-agent]')
      end
      should contain_package('dnsmasq').with(
        :ensure => 'present',
        :name   => platform_params[:dnsmasq_packages]
      )
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :dnsmasq_packages   => ['dnsmasq-base', 'dnsmasq-utils'],
        :dhcp_agent_package => 'quantum-dhcp-agent',
        :dhcp_agent_service => 'quantum-dhcp-agent' }
    end

    it_configures 'quantum dhcp agent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :dnsmasq_packages   => ['dnsmasq', 'dnsmasq-utils'],
        :dhcp_agent_service => 'quantum-dhcp-agent' }
    end

    it_configures 'quantum dhcp agent'
  end
end
