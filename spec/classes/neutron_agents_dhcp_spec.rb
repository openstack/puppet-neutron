require 'spec_helper'

describe 'neutron::agents::dhcp' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present',
      :enabled          => true,
      :debug            => false,
      :state_path       => '/var/lib/neutron',
      :resync_interval  => 30,
      :interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :dhcp_driver      => 'neutron.agent.linux.dhcp.Dnsmasq',
      :root_helper      => 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
      :use_namespaces   => true }
  end


  shared_examples_for 'neutron dhcp agent' do
    let :p do
      default_params.merge(params)
    end

    it { should include_class('neutron::params') }

    it_configures 'dnsmasq dhcp_driver'

    it 'configures dhcp_agent.ini' do
      should contain_neutron_dhcp_agent_config('DEFAULT/debug').with_value(p[:debug]);
      should contain_neutron_dhcp_agent_config('DEFAULT/state_path').with_value(p[:state_path]);
      should contain_neutron_dhcp_agent_config('DEFAULT/resync_interval').with_value(p[:resync_interval]);
      should contain_neutron_dhcp_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      should contain_neutron_dhcp_agent_config('DEFAULT/dhcp_driver').with_value(p[:dhcp_driver]);
      should contain_neutron_dhcp_agent_config('DEFAULT/root_helper').with_value(p[:root_helper]);
      should contain_neutron_dhcp_agent_config('DEFAULT/use_namespaces').with_value(p[:use_namespaces]);
    end

    it 'installs neutron dhcp agent package' do
      if platform_params.has_key?(:dhcp_agent_package)
        should contain_package('neutron-dhcp-agent').with(
          :name   => platform_params[:dhcp_agent_package],
          :ensure => p[:package_ensure]
        )
        should contain_package('neutron').with_before(/Package\[neutron-dhcp-agent\]/)
        should contain_package('neutron-dhcp-agent').with_before(/Neutron_dhcp_agent_config\[.+\]/)
        should contain_package('neutron-dhcp-agent').with_before(/Neutron_config\[.+\]/)
      else
        should contain_package('neutron').with_before(/Neutron_dhcp_agent_config\[.+\]/)
      end
    end

    it 'configures neutron dhcp agent service' do
      should contain_service('neutron-dhcp-service').with(
        :name    => platform_params[:dhcp_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :require => 'Class[Neutron]'
      )
    end
  end

  shared_examples_for 'dnsmasq dhcp_driver' do
    it 'installs dnsmasq packages' do
      if platform_params.has_key?(:dhcp_agent_package)
        should contain_package(platform_params[:dnsmasq_base_package]).with_before('Package[neutron-dhcp-agent]')
        should contain_package(platform_params[:dnsmasq_utils_package]).with_before('Package[neutron-dhcp-agent]')
      end
      should contain_package(platform_params[:dnsmasq_base_package]).with(
        :ensure => 'present',
        :name   => platform_params[:dnsmasq_base_package]
      )
      should contain_package(platform_params[:dnsmasq_utils_package]).with(
        :ensure => 'present',
        :name   => platform_params[:dnsmasq_utils_package]
      )
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :dnsmasq_base_package  => 'dnsmasq-base',
        :dnsmasq_utils_package => 'dnsmasq-utils',
        :dhcp_agent_package    => 'neutron-dhcp-agent',
        :dhcp_agent_service    => 'neutron-dhcp-agent' }
    end

    it_configures 'neutron dhcp agent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :dnsmasq_base_package  => 'dnsmasq',
        :dnsmasq_utils_package => 'dnsmasq-utils',
        :dhcp_agent_service    => 'neutron-dhcp-agent' }
    end

    it_configures 'neutron dhcp agent'
  end
end
