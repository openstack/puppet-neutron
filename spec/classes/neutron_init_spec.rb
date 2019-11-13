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

    context 'with amqp messaging' do
      it_behaves_like 'amqp support'
    end
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
      should contain_neutron_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('oslo_messaging_notifications/topics').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
    end

    it 'configures rabbit' do
      should contain_neutron_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('oslo_messaging_rabbit/heartbeat_in_pthread').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value( '<SERVICE DEFAULT>' )
      should contain_neutron_config('oslo_messaging_rabbit/kombu_missing_consumer_retry_timeout').with_value( '<SERVICE DEFAULT>' )
      should contain_neutron_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value( '<SERVICE DEFAULT>' )
      should contain_neutron_config('oslo_messaging_rabbit/kombu_compression').with_value( '<SERVICE DEFAULT>' )
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
      should contain_neutron_config('DEFAULT/allow_overlapping_ips').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/api_extensions_path').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/control_exchange').with_value('neutron')
      should contain_neutron_config('DEFAULT/state_path').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('oslo_concurrency/lock_path').with_value('$state_path/lock')
      should contain_neutron_config('DEFAULT/executor_thread_pool_size').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/rpc_response_timeout').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/vlan_transparent').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('agent/root_helper').with_value('sudo neutron-rootwrap /etc/neutron/rootwrap.conf')
      should contain_neutron_config('agent/root_helper_daemon').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('agent/report_interval').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples 'rabbit with heartbeat configured' do
    it 'in neutron.conf' do
      should contain_neutron_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('60')
      should contain_neutron_config('oslo_messaging_rabbit/heartbeat_rate').with_value('10')
      should contain_neutron_config('oslo_messaging_rabbit/heartbeat_in_pthread').with_value(true)
    end
  end

  shared_examples 'rabbit with durable queues' do
    it 'in neutron.conf' do
      should contain_neutron_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(true)
    end
  end

  shared_examples 'rabbit with non default transient_queues_ttl' do
    it 'in neutron.conf' do
      should contain_neutron_config('oslo_messaging_rabbit/rabbit_transient_queues_ttl').with_value(20)
    end
  end

  shared_examples 'rabbit_ha_queues set to false' do
    it 'in neutron.conf' do
      should contain_neutron_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(false)
    end
  end

  shared_examples 'notification_driver and notification_topics' do
    it 'in neutron.conf' do
      should contain_neutron_config('oslo_messaging_notifications/driver').with_value( params[:notification_driver] )
      should contain_neutron_config('oslo_messaging_notifications/topics').with_value( params[:notification_topics] )
      should contain_neutron_config('oslo_messaging_notifications/transport_url').with_value( params[:notification_transport_url] )
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
      should contain_neutron_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('30')
      should contain_neutron_config('oslo_messaging_rabbit/kombu_missing_consumer_retry_timeout').with_value('5')
      should contain_neutron_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('shuffle')
      should contain_neutron_config('oslo_messaging_rabbit/kombu_compression').with_value('gzip')
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

    context 'without required parameters' do

      context 'without kombu_ssl_keyfile parameter' do
        before { params.delete(:kombu_ssl_keyfile) }
        it { should raise_error(Puppet::Error, /The kombu_ssl_certfile and kombu_ssl_keyfile parameters must be used together/) }
      end
    end

  end

  shared_examples 'with state and lock paths set' do
    before { params.merge!(
      :state_path => 'state_path',
      :lock_path  => 'lock_path'
    )}
    it {
      should contain_neutron_config('DEFAULT/state_path').with_value('state_path')
      should contain_neutron_config('oslo_concurrency/lock_path').with_value('lock_path')
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
    it { should_not contain_neutron_config('DEFAULT/service_plugins') }
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
      should contain_neutron_config('DEFAULT/transport_url').with_value(params[:default_transport_url])
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

  shared_examples 'amqp support' do
    context 'with default amqp parameters' do
      it { should contain_neutron_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>') }
    end

    context 'with overridden amqp parameters' do
      before { params.merge!(
        :amqp_idle_timeout  => '60',
        :amqp_trace         => true,
        :amqp_ssl_ca_file   => '/path/to/ca.cert',
        :amqp_ssl_cert_file => '/path/to/certfile',
        :amqp_ssl_key_file  => '/path/to/key',
        :amqp_username      => 'amqp_user',
        :amqp_password      => 'password',
      ) }

      it { should contain_neutron_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/idle_timeout').with_value('60') }
      it { should contain_neutron_config('oslo_messaging_amqp/trace').with_value('true') }
      it { should contain_neutron_config('oslo_messaging_amqp/ssl_ca_file').with_value('/path/to/ca.cert') }
      it { should contain_neutron_config('oslo_messaging_amqp/ssl_cert_file').with_value('/path/to/certfile') }
      it { should contain_neutron_config('oslo_messaging_amqp/ssl_key_file').with_value('/path/to/key') }
      it { should contain_neutron_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>') }
      it { should contain_neutron_config('oslo_messaging_amqp/username').with_value('amqp_user') }
      it { should contain_neutron_config('oslo_messaging_amqp/password').with_value('password') }
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
        case facts[:osfamily]
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
