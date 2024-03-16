require 'spec_helper'

describe 'neutron::agents::metadata' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {
      :package_ensure => 'present',
      :enabled        => true,
      :shared_secret  => 'metadata-secret',
      :purge_config   => false,
    }
  end

  shared_examples 'neutron metadata agent' do

    it { should contain_class('neutron::params') }

    it 'configures neutron metadata agent service' do
      should contain_service('neutron-metadata').with(
        :name    => platform_params[:metadata_agent_service],
        :enable  => params[:enabled],
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('neutron-metadata').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-metadata').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end

      it 'should not manage the service' do
        should_not contain_service('neutron-metadata')
      end
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_metadata_agent_config').with({
        :purge => false
      })
    end

    it 'configures metadata_agent.ini' do
      should contain_neutron_metadata_agent_config('DEFAULT/debug').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/auth_ca_cert').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_client_cert').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_client_priv_key').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_metadata_host').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_metadata_port').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_metadata_protocol').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/metadata_workers').with(:value => facts[:os_workers])
      should contain_neutron_metadata_agent_config('DEFAULT/metadata_backlog').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_metadata_insecure').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/metadata_proxy_shared_secret').with(:value => params[:shared_secret]).with_secret(true)
      should contain_neutron_metadata_agent_config('agent/report_interval').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_metadata_agent_config('DEFAULT/rpc_response_max_timeout').with(:value => '<SERVICE DEFAULT>')
    end
  end

  shared_examples 'neutron metadata agent with auth_ca_cert set' do
    let :params do
      {
        :auth_ca_cert         => '/some/cert',
        :shared_secret        => '42',
        :nova_client_cert     => '/nova/cert',
        :nova_client_priv_key => '/nova/key',
        :metadata_insecure    => true,
      }
    end

    it 'configures certificate' do
      should contain_neutron_metadata_agent_config('DEFAULT/auth_ca_cert').with_value('/some/cert')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_client_cert').with_value('/nova/cert')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_client_priv_key').with_value('/nova/key')
      should contain_neutron_metadata_agent_config('DEFAULT/nova_metadata_insecure').with_value(true)
    end
  end

  shared_examples 'neutron::agents::metadata on Debian' do
    it 'installs neutron metadata agent package' do
      should contain_package('neutron-metadata').with(
        :ensure => params[:package_ensure],
        :name   => platform_params[:metadata_agent_package],
        :tag    => ['openstack', 'neutron-package'],
      )
    end

    it 'configures subscription to neutron-metadata package' do
      should contain_service('neutron-metadata').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-metadata').that_notifies('Anchor[neutron::service::end]')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          {
            :metadata_agent_package => 'neutron-metadata-agent',
            :metadata_agent_service => 'neutron-metadata-agent'
          }
        when 'RedHat'
          {
            :metadata_agent_service => 'neutron-metadata-agent'
          }
        end
      end

      it_behaves_like 'neutron metadata agent'
      it_behaves_like 'neutron metadata agent with auth_ca_cert set'

      if facts[:os]['family'] == 'Debian'
        it_behaves_like 'neutron::agents::metadata on Debian'
      end
    end
  end
end
