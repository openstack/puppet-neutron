require 'spec_helper'

describe 'neutron::agents::ovn_metadata' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :params do
    { :package_ensure    => 'present',
      :debug             => false,
      :enabled           => true,
      :shared_secret     => 'metadata-secret',
      :purge_config      => false,
      :ovsdb_connection  => 'tcp:127.0.0.1:6640',
      :root_helper       => 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
      :state_path        => '/var/lib/neutron/',
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default',
    }
  end

  shared_examples_for 'ovn metadata agent' do

    it { is_expected.to contain_class('neutron::params') }

    it 'configures ovn metadata agent service' do
      is_expected.to contain_service('ovn-metadata').with(
        :name    => platform_params[:ovn_metadata_agent_service],
        :enable  => params[:enabled],
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      is_expected.to contain_service('ovn-metadata').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('ovn-metadata').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        is_expected.to contain_service('ovn-metadata').without_ensure
      end
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('ovn_metadata_agent_config').with({
        :purge => false
      })
    end

    it 'configures ovn_metadata_agent.ini' do
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/debug').with(:value => params[:debug])
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/auth_ca_cert').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_client_cert').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_client_priv_key').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_ip').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_host').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_port').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_protocol').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/metadata_workers').with(:value => facts[:os_workers])
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/metadata_backlog').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_insecure').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/state_path').with(:value => params[:state_path])
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/metadata_proxy_shared_secret').with(:value => params[:shared_secret])
      is_expected.to contain_ovn_metadata_agent_config('agent/root_helper').with(:value => params[:root_helper])
      is_expected.to contain_ovn_metadata_agent_config('agent/root_helper_daemon').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('ovs/ovsdb_connection_timeout').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ovn_metadata_agent_config('ovs/ovsdb_connection').with(:value => params[:ovsdb_connection])
      is_expected.to contain_ovn_metadata_agent_config('ovn/ovn_sb_connection').with(:value => '<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'ovn metadata agent with auth_ca_cert set' do
    let :params do
      { :auth_ca_cert         => '/some/cert',
        :shared_secret        => '42',
        :nova_client_cert     => '/nova/cert',
        :nova_client_priv_key => '/nova/key',
        :metadata_insecure    => true,
      }
    end

    it 'configures certificate' do
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/auth_ca_cert').with_value('/some/cert')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_client_cert').with_value('/nova/cert')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_client_priv_key').with_value('/nova/key')
      is_expected.to contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_insecure').with_value(true)
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge(
        { :osfamily => 'Debian' }
      ))
    end

    let :platform_params do
      { :ovn_metadata_agent_service => 'networking-ovn-metadata-agent' }
    end
    
    it_configures 'ovn metadata agent'
    it_configures 'ovn metadata agent with auth_ca_cert set'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :platform_params do
      { :ovn_metadata_agent_package => 'networking-ovn-metadata-agent',
        :ovn_metadata_agent_service => 'networking-ovn-metadata-agent' }
    end

    it 'installs ovn metadata agent package' do
      is_expected.to contain_package('ovn-metadata').with(
        :ensure => params[:package_ensure],
        :name   => platform_params[:ovn_metadata_agent_package],
        :tag    => ['openstack', 'neutron-package'],
      )
    end

    it_configures 'ovn metadata agent'
    it_configures 'ovn metadata agent with auth_ca_cert set'
    it 'configures subscription to ovn-metadata package' do
      is_expected.to contain_service('ovn-metadata').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('ovn-metadata').that_notifies('Anchor[neutron::service::end]')
    end
  end
end
