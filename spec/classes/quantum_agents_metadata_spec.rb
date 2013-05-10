require 'spec_helper'

describe 'quantum::agents::metadata' do

  let :pre_condition do
    "class { 'quantum': rabbit_password => 'passw0rd' }"
  end

  let :params do
    { :package_ensure   => 'present',
      :debug            => false,
      :enabled          => true,
      :auth_url         => 'http://localhost:35357/v2.0',
      :auth_region      => 'RegionOne',
      :auth_tenant      => 'services',
      :auth_user        => 'quantum',
      :auth_password    => 'password',
      :metadata_ip      => '127.0.0.1',
      :metadata_port    => '8775',
      :shared_secret    => 'metadata-secret'
    }
  end

  shared_examples_for 'quantum metadata agent' do

    it { should include_class('quantum::params') }

    it 'configures quantum metadata agent service' do
      should contain_service('quantum-metadata').with(
        :name    => platform_params[:metadata_agent_service],
        :enable  => params[:enabled],
        :ensure => 'running',
        :require => 'Class[Quantum]'
      )
    end

    it 'configures metadata_agent.ini' do
      should contain_quantum_metadata_agent_config('DEFAULT/debug').with(:value => params[:debug])
      should contain_quantum_metadata_agent_config('DEFAULT/auth_url').with(:value => params[:auth_url])
      should contain_quantum_metadata_agent_config('DEFAULT/auth_region').with(:value => params[:auth_region])
      should contain_quantum_metadata_agent_config('DEFAULT/admin_tenant_name').with(:value => params[:auth_tenant])
      should contain_quantum_metadata_agent_config('DEFAULT/admin_user').with(:value => params[:auth_user])
      should contain_quantum_metadata_agent_config('DEFAULT/admin_password').with(:value => params[:auth_password])
      should contain_quantum_metadata_agent_config('DEFAULT/nova_metadata_ip').with(:value => params[:metadata_ip])
      should contain_quantum_metadata_agent_config('DEFAULT/nova_metadata_port').with(:value => params[:metadata_port])
      should contain_quantum_metadata_agent_config('DEFAULT/metadata_proxy_shared_secret').with(:value => params[:shared_secret])
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :metadata_agent_package => 'quantum-metadata-agent',
        :metadata_agent_service => 'quantum-metadata-agent' }
    end

    it 'installs quantum metadata agent package' do
      should contain_package('quantum-metadata').with(
        :ensure => params[:package_ensure],
        :name   => platform_params[:metadata_agent_package]
      )
    end

    it_configures 'quantum metadata agent'

  end

  context 'on Red Hat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :metadata_agent_service => 'quantum-metadata-agent' }
    end

    it_configures 'quantum metadata agent'

  end

end
