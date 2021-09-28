require 'spec_helper'

describe 'neutron::agents::ovn_metadata' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {
      :package_ensure   => 'present',
      :debug            => false,
      :enabled          => true,
      :shared_secret    => 'metadata-secret',
      :purge_config     => false,
      :ovsdb_connection => 'tcp:127.0.0.1:6640',
      :root_helper      => 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
      :state_path       => '/var/lib/neutron/',
    }
  end

  shared_examples 'ovn metadata agent' do
    it { should contain_class('neutron::params') }

    it 'configures ovn metadata agent service' do
      should contain_service('ovn-metadata').with(
        :name    => platform_params[:ovn_metadata_agent_service],
        :enable  => params[:enabled],
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('ovn-metadata').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('ovn-metadata').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end

      it 'should not start/stop service' do
        should contain_service('ovn-metadata').without_ensure
      end
    end

    it 'passes purge to resource' do
      should contain_resources('ovn_metadata_agent_config').with({
        :purge => false
      })
    end

    it 'configures ovn_metadata_agent.ini' do
      should contain_ovn_metadata_agent_config('DEFAULT/debug').with(:value => params[:debug])
      should contain_ovn_metadata_agent_config('DEFAULT/auth_ca_cert').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_client_cert').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_client_priv_key').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_ip').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_host').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_port').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_protocol').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/metadata_workers').with(:value => 2)
      should contain_ovn_metadata_agent_config('DEFAULT/metadata_backlog').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_insecure').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('DEFAULT/state_path').with(:value => params[:state_path])
      should contain_ovn_metadata_agent_config('DEFAULT/metadata_proxy_shared_secret').with(:value => params[:shared_secret])
      should contain_ovn_metadata_agent_config('agent/root_helper').with(:value => params[:root_helper])
      should contain_ovn_metadata_agent_config('agent/root_helper_daemon').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('ovs/ovsdb_connection_timeout').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('ovs/ovsdb_connection').with(:value => params[:ovsdb_connection])
      should contain_ovn_metadata_agent_config('ovn/ovn_sb_connection').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('ovn/ovn_remote_probe_interval').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('ovn/ovsdb_retry_max_interval').with(:value => '<SERVICE DEFAULT>')
      should contain_ovn_metadata_agent_config('ovn/ovsdb_probe_interval').with(:value => '<SERVICE DEFAULT>')
    end

    it 'installs ovn metadata agent package' do
      should contain_package('ovn-metadata').with(
        :ensure => params[:package_ensure],
        :name   => platform_params[:ovn_metadata_agent_package],
        :tag    => ['openstack', 'neutron-package'],
      )
    end

    it 'configures subscription to ovn-metadata package' do
      should contain_service('ovn-metadata').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('ovn-metadata').that_notifies('Anchor[neutron::service::end]')
    end
  end

  shared_examples 'ovn metadata agent with auth_ca_cert set' do
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
      should contain_ovn_metadata_agent_config('DEFAULT/auth_ca_cert').with_value('/some/cert')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_client_cert').with_value('/nova/cert')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_client_priv_key').with_value('/nova/key')
      should contain_ovn_metadata_agent_config('DEFAULT/nova_metadata_insecure').with_value(true)
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
        case facts[:osfamily]
        when 'Debian'
          { :ovn_metadata_agent_package => 'neutron-ovn-metadata-agent',
            :ovn_metadata_agent_service => 'neutron-ovn-metadata-agent' }
        when 'RedHat'
          { :ovn_metadata_agent_package => 'openstack-neutron-ovn-metadata-agent',
            :ovn_metadata_agent_service => 'neutron-ovn-metadata-agent' }
        end
      end

      it_behaves_like 'ovn metadata agent'
      it_behaves_like 'ovn metadata agent with auth_ca_cert set'
    end
  end
end
