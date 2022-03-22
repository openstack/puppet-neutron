require 'spec_helper'

describe 'neutron::agents::dhcp' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {}
  end

  let :default_params do
    {
      :package_ensure           => 'present',
      :enabled                  => true,
      :state_path               => '/var/lib/neutron',
      :resync_interval          => 30,
      :interface_driver         => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :root_helper              => 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
      :enable_isolated_metadata => false,
      :enable_metadata_network  => false,
      :purge_config             => false
    }
  end

  shared_examples 'neutron::agents::dhcp' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'configures dhcp_agent.ini' do
      should contain_neutron_dhcp_agent_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('DEFAULT/state_path').with_value(p[:state_path]);
      should contain_neutron_dhcp_agent_config('DEFAULT/resync_interval').with_value(p[:resync_interval]);
      should contain_neutron_dhcp_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      should contain_neutron_dhcp_agent_config('DEFAULT/dhcp_driver').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('DEFAULT/root_helper').with_value(p[:root_helper]);
      should contain_neutron_dhcp_agent_config('DEFAULT/enable_isolated_metadata').with_value(p[:enable_isolated_metadata]);
      should contain_neutron_dhcp_agent_config('DEFAULT/force_metadata').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('DEFAULT/enable_metadata_network').with_value(p[:enable_metadata_network]);
      should contain_neutron_dhcp_agent_config('DEFAULT/dhcp_broadcast_reply').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_local_resolv').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_enable_addr6_list').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('agent/availability_zone').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('agent/report_interval').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('OVS/ovsdb_connection').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('OVS/integration_bridge').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('OVS/ssl_key_file').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('OVS/ssl_cert_file').with_value('<SERVICE DEFAULT>');
      should contain_neutron_dhcp_agent_config('OVS/ssl_ca_cert_file').with_value('<SERVICE DEFAULT>');
    end

    it 'installs neutron-dhcp-agent package' do
      if platform_params.has_key?(:dhcp_agent_package)
        should contain_package('neutron-dhcp-agent').with(
          :name   => platform_params[:dhcp_agent_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        should contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
        should contain_package('neutron-dhcp-agent').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron-dhcp-agent').that_notifies('Anchor[neutron::install::end]')
      else
        should contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    it 'configures neutron-dhcp-agent service' do
      should contain_service('neutron-dhcp-service').with(
        :name    => platform_params[:dhcp_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('neutron-dhcp-service').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-dhcp-service').that_notifies('Anchor[neutron::service::end]')
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_dhcp_agent_config').with({
        :purge => false
      })
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        should contain_service('neutron-dhcp-service').without_ensure
      end
    end

    context 'when enabling isolated metadata only' do
      before :each do
        params.merge!(:enable_isolated_metadata => true, :enable_metadata_network => false)
      end
      it 'should enable isolated_metadata only' do
        should contain_neutron_dhcp_agent_config('DEFAULT/enable_isolated_metadata').with_value('true');
        should contain_neutron_dhcp_agent_config('DEFAULT/enable_metadata_network').with_value('false');
      end
    end

    context 'when enabling isolated metadata with metadata networks' do
      before :each do
        params.merge!(:enable_isolated_metadata => true, :enable_metadata_network => true)
      end
      it 'should enable both isolated_metadata and metadata_network' do
        should contain_neutron_dhcp_agent_config('DEFAULT/enable_isolated_metadata').with_value('true');
        should contain_neutron_dhcp_agent_config('DEFAULT/enable_metadata_network').with_value('true');
      end
    end

    context 'when enabling metadata networks without enabling isolated metadata or force metadata' do
      before :each do
        params.merge!(:enable_isolated_metadata => false, :enable_force_metadata => false, :enable_metadata_network => true)
      end

      it { should raise_error(Puppet::Error, /enable_metadata_network to true requires enable_isolated_metadata or enable_force_metadata also enabled./) }
    end

    context 'when enabling force metadata only' do
      before :each do
        params.merge!(:enable_force_metadata => true, :enable_metadata_network => false)
      end
      it 'should enable force_metadata only' do
        should contain_neutron_dhcp_agent_config('DEFAULT/force_metadata').with_value('true');
        should contain_neutron_dhcp_agent_config('DEFAULT/enable_metadata_network').with_value('false');
      end
    end

    context 'when enabling force metadata with metadata networks' do
      before :each do
        params.merge!(:enable_force_metadata => true, :enable_metadata_network => true)
      end
      it 'should enable both force_metadata and metadata_network' do
        should contain_neutron_dhcp_agent_config('DEFAULT/force_metadata').with_value('true');
        should contain_neutron_dhcp_agent_config('DEFAULT/enable_metadata_network').with_value('true');
      end
    end

    context 'when availability zone is set' do
      before :each do
        params.merge!(:availability_zone => 'zone1')
      end
      it 'should configure availability zone' do
        should contain_neutron_dhcp_agent_config('agent/availability_zone').with_value(p[:availability_zone]);
      end
    end

    context 'with SSL configuration' do
      before do
        params.merge!({
          :ovsdb_connection          => 'ssl:127.0.0.1:6639',
          :ovsdb_agent_ssl_key_file  => '/tmp/dummy.pem',
          :ovsdb_agent_ssl_cert_file => '/tmp/dummy.crt',
          :ovsdb_agent_ssl_ca_file   => '/tmp/ca.crt'
        })
      end
      it 'configures neutron SSL settings' do
        should contain_neutron_dhcp_agent_config('OVS/ovsdb_connection').with_value(params[:ovsdb_connection])
        should contain_neutron_dhcp_agent_config('OVS/ssl_key_file').with_value(params[:ovsdb_agent_ssl_key_file])
        should contain_neutron_dhcp_agent_config('OVS/ssl_cert_file').with_value(params[:ovsdb_agent_ssl_cert_file])
        should contain_neutron_dhcp_agent_config('OVS/ssl_ca_cert_file').with_value(params[:ovsdb_agent_ssl_ca_file])
      end
    end

    context 'with SSL enabled, but missing file config' do
      before do
        params.merge!({
          :ovsdb_connection => 'ssl:127.0.0.1:6639'
        })
      end
      it 'fails to configure' do
        should raise_error(Puppet::Error)
      end
    end

    context 'when enabling dhcp-host entry with list of addresses' do
      before :each do
        params.merge!(:dnsmasq_enable_addr6_list => true)
      end
      it 'should enabling dhcp-host entry with list of addresses' do
        should contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_enable_addr6_list').with_value('true');
      end
    end

    context 'with dnsmasq_config_file specified' do
      before do
        params.merge!(
          :dnsmasq_config_file => '/foo'
        )
      end
      it 'configures dnsmasq_config_file' do
        should contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_config_file').with_value(params[:dnsmasq_config_file])
      end
    end

    context 'enable advertisement of the DNS resolver on the host.' do
      before do
        params.merge!(
          :dnsmasq_local_resolv => true
        )
      end
      it 'configures dnsmasq_local_resolv' do
        should contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_local_resolv').with_value(params[:dnsmasq_local_resolv])
      end
    end

    context 'with dnsmasq_dns_servers set' do
      before do
        params.merge!(
          :dnsmasq_dns_servers => ['1.2.3.4','5.6.7.8']
        )
      end
      it 'should set dnsmasq_dns_servers' do
        should contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_dns_servers').with_value(params[:dnsmasq_dns_servers].join(','))
      end
    end
  end

  shared_examples 'neutron::agents::dhcp on Debian' do
    it 'configures subscription to neutron-dhcp-agent package' do
      should contain_service('neutron-dhcp-service').that_subscribes_to('Anchor[neutron::service::begin]')
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
          {
            :dhcp_agent_package    => 'neutron-dhcp-agent',
            :dhcp_agent_service    => 'neutron-dhcp-agent'
          }
        when 'RedHat'
          {
            :dhcp_agent_service    => 'neutron-dhcp-agent'
          }
        end
      end

      it_behaves_like 'neutron::agents::dhcp'

      if facts[:osfamily] == 'Debian'
        it_behaves_like 'neutron::agents::dhcp on Debian'
      end
    end
  end
end
