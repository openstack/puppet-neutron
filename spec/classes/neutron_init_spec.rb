require 'spec_helper'

describe 'neutron' do
  let :params do
    {
      :package_ensure => 'present',
      :core_plugin    => 'ml2',
      :auth_strategy  => 'keystone',
      :purge_config   => false,
    }
  end

  shared_examples 'neutron' do
    it_behaves_like 'a neutron base installation'

    context 'with rabbitmq heartbeat configured' do
      before { params.merge!( 
        :rabbit_heartbeat_timeout_threshold => '60',
        :rabbit_heartbeat_rate => '10',
        :rabbit_heartbeat_in_pthread => true,
      ) }
      it_behaves_like 'rabbit with heartbeat configured'
    end

    context 'with rabbitmq durable queues configured' do
      before { params.merge!( :amqp_durable_queues => true ) }
      it_behaves_like 'rabbit with durable queues'
    end

    context 'with rabbitmq non default transient_queues_ttl' do
      before { params.merge!( :rabbit_transient_queues_ttl => 20 ) }
      it_behaves_like 'rabbit with non default transient_queues_ttl'
    end

    it_behaves_like 'with SSL enabled with kombu'
    it_behaves_like 'with SSL enabled without kombu'
    it_behaves_like 'with SSL disabled'
    it_behaves_like 'with SSL and kombu wrongly configured'
    it_behaves_like 'with SSL socket options set'
    it_behaves_like 'with SSL socket options set with wrong parameters'
    it_behaves_like 'with SSL socket options left by default'
    it_behaves_like 'without service_plugins'
    it_behaves_like 'with service_plugins'
    it_behaves_like 'with host defined'
    it_behaves_like 'with dns_domain defined'
    it_behaves_like 'with transport_url defined'
    it_behaves_like 'with rootwrap daemon'
    it_behaves_like 'with max_allowed_address_pair defined'
    it_behaves_like 'when disabling vlan_transparent'
    it_behaves_like 'when enabling vlan_transparent'
  end

  shared_examples 'a neutron base installation' do
    it { should contain_class('neutron::params') }

    it 'installs neutron package' do
      should contain_package('neutron').with(
        :ensure => 'present',
        :name   => platform_params[:common_package_name],
        :tag    => ['openstack', 'neutron-package'],
      )
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_config').with({
        :purge => false
      })
    end

    it 'configures messaging notifications' do
      should contain_oslo__messaging__notifications('neutron_config').with(
        :transport_url => '<SERVICE DEFAULT>',
        :driver        => '<SERVICE DEFAULT>',
        :topics        => '<SERVICE DEFAULT>',
      )
    end

    it 'configures rabbit' do
      should contain_oslo__messaging__rabbit('neutron_config').with(
        :heartbeat_timeout_threshold          => '<SERVICE DEFAULT>',
        :heartbeat_rate                       => '<SERVICE DEFAULT>',
        :heartbeat_in_pthread                 => '<SERVICE DEFAULT>',
        :rabbit_qos_prefetch_count            => '<SERVICE DEFAULT>',
        :rabbit_use_ssl                       => '<SERVICE DEFAULT>',
        :rabbit_transient_queues_ttl          => '<SERVICE DEFAULT>',
        :kombu_reconnect_delay                => '<SERVICE DEFAULT>',
        :kombu_missing_consumer_retry_timeout => '<SERVICE DEFAULT>',
        :kombu_failover_strategy              => '<SERVICE DEFAULT>',
        :kombu_compression                    => '<SERVICE DEFAULT>',
        :amqp_durable_queues                  => '<SERVICE DEFAULT>',
        :rabbit_ha_queues                     => '<SERVICE DEFAULT>',
        :rabbit_quorum_queue                  => '<SERVICE DEFAULT>',
        :rabbit_transient_quorum_queue        => '<SERVICE DEFAULT>',
        :rabbit_quorum_delivery_limit         => '<SERVICE DEFAULT>',
        :rabbit_quorum_max_memory_length      => '<SERVICE DEFAULT>',
        :rabbit_quorum_max_memory_bytes       => '<SERVICE DEFAULT>',
        :enable_cancel_on_failover            => '<SERVICE DEFAULT>',
      )
    end

    it 'configures neutron.conf' do
      should contain_neutron_config('DEFAULT/bind_host').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/bind_port').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/auth_strategy').with_value('keystone')
      should contain_neutron_config('DEFAULT/core_plugin').with_value( params[:core_plugin] )
      should contain_neutron_config('DEFAULT/base_mac').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/dhcp_lease_duration').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/host').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/dns_domain').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/dhcp_agents_per_network').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/global_physnet_mtu').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/dhcp_agent_notification').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/allow_bulk').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/api_extensions_path').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/control_exchange').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/state_path').with_value('<SERVICE DEFAULT>')
      should contain_oslo__concurrency('neutron_config').with(
        :lock_path => '$state_path/lock'
      )
      should contain_oslo__messaging__default('neutron_config').with(
        :executor_thread_pool_size => '<SERVICE DEFAULT>',
        :transport_url             => '<SERVICE DEFAULT>',
        :rpc_response_timeout      => '<SERVICE DEFAULT>',
        :control_exchange          => '<SERVICE DEFAULT>',
      )

      should contain_neutron_config('DEFAULT/vlan_transparent').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('agent/root_helper').with_value('sudo neutron-rootwrap /etc/neutron/rootwrap.conf')
      should contain_neutron_config('agent/root_helper_daemon').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('agent/report_interval').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples 'rabbit with heartbeat configured' do
    it 'in neutron.conf' do
      should contain_oslo__messaging__rabbit('neutron_config').with(
        :heartbeat_timeout_threshold => '60',
        :heartbeat_rate              => '10',
        :heartbeat_in_pthread        => true,
      )
    end
  end

  shared_examples 'rabbit with durable queues' do
    it 'in neutron.conf' do
      should contain_oslo__messaging__rabbit('neutron_config').with(
        :amqp_durable_queues => true
      )
    end
  end

  shared_examples 'rabbit with non default transient_queues_ttl' do
    it 'in neutron.conf' do
      should contain_oslo__messaging__rabbit('neutron_config').with(
        :rabbit_transient_queues_ttl => 20
      )
    end
  end

  shared_examples 'rabbit_ha_queues set to false' do
    it 'in neutron.conf' do
      should contain_oslo__messaging__rabbit('neutron_config').with(
        :rabbit_ha_queues => true
      )
    end
  end

  shared_examples 'notification_driver and notification_topics' do
    it 'in neutron.conf' do
      should contain_oslo__messaging__notifications('neutron_config').with(
        :transport_url => params[:notification_transport_url],
        :driver        => params[:notification_driver],
        :topics        => params[:notification_topics],
      )
    end
  end

  shared_examples 'with SSL socket options set' do
    before do
      params.merge!(
        :use_ssl   => true,
        :cert_file => '/path/to/cert',
        :key_file  => '/path/to/key',
        :ca_file   => '/path/to/ca'
      )
    end

    it { should contain_neutron_config('DEFAULT/use_ssl').with_value('true') }
    it { should contain_neutron_config('ssl/cert_file').with_value('/path/to/cert') }
    it { should contain_neutron_config('ssl/key_file').with_value('/path/to/key') }
    it { should contain_neutron_config('ssl/ca_file').with_value('/path/to/ca') }
  end

  shared_examples 'with SSL socket options set with wrong parameters' do
    before do
      params.merge!(
        :use_ssl  => true,
        :key_file => '/path/to/key',
        :ca_file  => '/path/to/ca'
      )
    end

    it { should raise_error(Puppet::Error, /The cert_file parameter is required when use_ssl is set to true/) }
  end

  shared_examples 'with SSL socket options left by default' do

    it { should contain_neutron_config('DEFAULT/use_ssl').with_value('<SERVICE DEFAULT>') }
    it { should contain_neutron_config('ssl/cert_file').with_value('<SERVICE DEFAULT>') }
    it { should contain_neutron_config('ssl/key_file').with_value('<SERVICE DEFAULT>') }
    it { should contain_neutron_config('ssl/ca_file').with_value('<SERVICE DEFAULT>') }
  end

  shared_examples 'with SSL socket options set and no ca_file' do
    before do
      params.merge!(
        :use_ssl   => true,
        :cert_file => '/path/to/cert',
        :key_file  => '/path/to/key'
      )
    end

    it { should contain_neutron_config('DEFAULT/use_ssl').with_value('true') }
    it { should contain_neutron_config('ssl/cert_file').with_value('/path/to/cert') }
    it { should contain_neutron_config('ssl/key_file').with_value('/path/to/key') }
    it { should contain_neutron_config('ssl/ca_file').with_ensure('absent') }
  end

  shared_examples 'with SSL socket options disabled with ca_file' do
    before do
      params.merge!(
        :use_ssl => false,
        :ca_file => '/path/to/ca'
      )
    end

    it { should raise_error(Puppet::Error, /The ca_file parameter requires that use_ssl to be set to true/) }
  end

  shared_examples 'with non-default kombu options' do
    before do
      params.merge!(
        :kombu_missing_consumer_retry_timeout => '5',
        :kombu_failover_strategy              => 'shuffle',
        :kombu_compression                    => 'gzip',
        :kombu_reconnect_delay                => '30',
      )
    end

    it do
      should contain_oslo__messaging__rabbit('neutron_config').with(
        :kombu_reconnect_delay                => '30',
        :kombu_missing_consumer_retry_timeout => '5',
        :kombu_failover_strategy              => 'shuffle',
        :kombu_compression                    => 'gzip',
      )
    end
  end

  shared_examples 'with SSL enabled with kombu' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true,
        :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
        :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
        :kombu_ssl_version  => 'TLSv1'
      )
    end

    it { should contain_oslo__messaging__rabbit('neutron_config').with(
      :rabbit_use_ssl     => true,
      :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
      :kombu_ssl_certfile => '/path/to/ssl/cert/file',
      :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
      :kombu_ssl_version  => 'TLSv1'
    )}
  end

  shared_examples 'with SSL enabled without kombu' do
    before do
      params.merge!(
        :rabbit_use_ssl => true
      )
    end

    it { should contain_oslo__messaging__rabbit('neutron_config').with(
      :rabbit_use_ssl => true,
    )}
  end

  shared_examples 'with SSL disabled' do

    it { should contain_oslo__messaging__rabbit('neutron_config').with(
      :rabbit_use_ssl => '<SERVICE DEFAULT>',
    )}
  end

  shared_examples 'with SSL and kombu wrongly configured' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true,
        :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile'
      )
    end

  end

  shared_examples 'with state and lock paths set' do
    before { params.merge!(
      :state_path => 'state_path',
      :lock_path  => 'lock_path'
    )}
    it {
      should contain_neutron_config('DEFAULT/state_path').with_value('state_path')
      should contain_oslo__concurrency('neutron_config').with(
        :lock_path => 'lock_path'
      )
    }
  end

  shared_examples 'when disabling vlan_transparent' do
    before do
      params.merge!(
        :vlan_transparent => false
      )
    end
    it do
      should contain_neutron_config('DEFAULT/vlan_transparent').with_value(false)
    end
  end

  shared_examples 'when enabling vlan_transparent' do
    before do
      params.merge!(
        :vlan_transparent => true
      )
    end
    it do
      should contain_neutron_config('DEFAULT/vlan_transparent').with_value(true)
    end
  end

  shared_examples 'without service_plugins' do
    it do
      should contain_neutron_config('DEFAULT/service_plugins').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples 'with service_plugins' do
    before do
      params.merge!(
        :service_plugins => ['router','firewall','vpnaas','metering','qos']
      )
    end

    it do
      should contain_neutron_config('DEFAULT/service_plugins').with_value('router,firewall,vpnaas,metering,qos')
    end
  end

  shared_examples 'with global_physnet_mtu defined' do
    before do
      params.merge!(
        :global_physnet_mtu => 9000
      )
    end

    it do
      should contain_neutron_config('DEFAULT/global_physnet_mtu').with_value(params[:global_physnet_mtu])
    end
  end

  shared_examples 'with host defined' do
    before do
      params.merge!(
        :host => 'test-001.example.org'
      )
    end

    it do
      should contain_neutron_config('DEFAULT/host').with_value(params[:host])
    end
  end

  shared_examples 'with dns_domain defined' do
    before do
      params.merge!(
        :dns_domain => 'testlocal'
      )
    end

    it do
      should contain_neutron_config('DEFAULT/dns_domain').with_value(params[:dns_domain])
    end
  end

  shared_examples 'with transport_url defined' do
    before do
      params.merge!(
        :default_transport_url => 'rabbit://rabbit_user:password@localhost:5673'
      )
    end

    it do
      should contain_oslo__messaging__default('neutron_config').with(
        :transport_url => params[:default_transport_url]
      )
    end
  end

  shared_examples 'with rootwrap daemon' do
    before do
      params.merge!(
        :root_helper_daemon => 'sudo neutron-rootwrap-daemon /etc/neutron/rootwrap.conf'
      )
    end

    it do
      should contain_neutron_config('agent/root_helper_daemon').with_value(params[:root_helper_daemon])
    end
  end

  shared_examples 'with max_allowed_address_pair defined' do
    before do
      params.merge!(
        :max_allowed_address_pair => '50'
      )
    end

    it do
      should contain_neutron_config('DEFAULT/max_allowed_address_pair').with_value(params[:max_allowed_address_pair])
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
            :common_package_name => 'neutron-common'
          }
        when 'RedHat'
          {
            :common_package_name => 'openstack-neutron'
          }
        end
      end

      it_behaves_like 'neutron'
    end
  end
end
