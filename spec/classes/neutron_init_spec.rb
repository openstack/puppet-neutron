require 'spec_helper'

describe 'neutron' do

  let :params do
    { :package_ensure        => 'present',
      :core_plugin           => 'linuxbridge',
      :auth_strategy         => 'keystone',
      :rabbit_password       => 'guest',
      :log_dir               => '/var/log/neutron',
      :purge_config          => false,
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron' do

    context 'and if rabbit_host parameter is provided' do
      it_configures 'a neutron base installation'
    end

    context 'and if rabbit_hosts parameter is provided' do

      context 'with one server' do
        before { params.merge!( :rabbit_hosts => ['127.0.0.1:5672'] ) }
        it_configures 'a neutron base installation'
        it_configures 'rabbit HA with a single virtual host'
      end

      context 'with multiple servers' do
        before { params.merge!( :rabbit_hosts => ['rabbit1:5672', 'rabbit2:5672'] ) }
        it_configures 'a neutron base installation'
        it_configures 'rabbit HA with multiple hosts'
      end

      context 'with rabbit_ha_queues set to false and with rabbit_hosts' do
        before { params.merge!( :rabbit_ha_queues => 'false',
                                :rabbit_hosts => ['rabbit:5673'] ) }
        it_configures 'rabbit_ha_queues set to false'
      end

      context 'with non-default notification options' do
        before { params.merge!( :notification_driver => 'messagingv2',
                                :notification_topics => 'notifications',
                                :notification_transport_url => 'rabbit://me:passwd@host:5672/virtual_host' ) }
        it_configures 'notification_driver and notification_topics'
      end

      it 'configures logging' do
        is_expected.to contain_neutron_config('DEFAULT/log_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_config('DEFAULT/log_dir').with_value(params[:log_dir])
        is_expected.to contain_neutron_config('DEFAULT/use_stderr').with_value('<SERVICE DEFAULT>')
      end

    end

    context 'with rabbitmq heartbeat configured' do
      before { params.merge!( :rabbit_heartbeat_timeout_threshold => '60', :rabbit_heartbeat_rate => '10' ) }
      it_configures 'rabbit with heartbeat configured'
    end

    context 'with rabbitmq durable queues configured' do
      before { params.merge!( :amqp_durable_queues => true ) }
      it_configures 'rabbit with durable queues'
    end

    context 'with rabbitmq non default transient_queues_ttl' do
      before { params.merge!( :rabbit_transient_queues_ttl => 20 ) }
      it_configures 'rabbit with non default transient_queues_ttl'
    end


    it_configures 'with SSL enabled with kombu'
    it_configures 'with SSL enabled without kombu'
    it_configures 'with SSL disabled'
    it_configures 'with SSL and kombu wrongly configured'
    it_configures 'with SSL socket options set'
    it_configures 'with SSL socket options set with wrong parameters'
    it_configures 'with SSL socket options left by default'
    it_configures 'with syslog disabled'
    it_configures 'with syslog enabled'
    it_configures 'with log_file specified'
    it_configures 'without service_plugins'
    it_configures 'with service_plugins'
    it_configures 'without memcache_servers'
    it_configures 'with memcache_servers'
    it_configures 'with host defined'
    it_configures 'with dns_domain defined'
    it_configures 'with transport_url defined'
    it_configures 'with rootwrap daemon'

    context 'with amqp rpc_backend value' do
      it_configures 'amqp support'
    end
  end

  shared_examples_for 'a neutron base installation' do

    it { is_expected.to contain_class('neutron::params') }

    it 'installs neutron package' do
      is_expected.to contain_package('neutron').with(
        :ensure => 'present',
        :name   => platform_params[:common_package_name],
        :tag    => ['openstack', 'neutron-package'],
      )
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_config').with({
        :purge => false
      })
    end

    it 'configures messaging notifications' do
      is_expected.to contain_neutron_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_notifications/topics').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
    end

    it 'configures credentials for rabbit' do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_userid').with_value( '<SERVICE DEFAULT>' )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_password').with_value( params[:rabbit_password] )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_password').with_secret( true )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_virtual_host').with_value( '<SERVICE DEFAULT>' )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value( '<SERVICE DEFAULT>' )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_missing_consumer_retry_timeout').with_value( '<SERVICE DEFAULT>' )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value( '<SERVICE DEFAULT>' )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_compression').with_value( '<SERVICE DEFAULT>' )
    end

    it 'configures neutron.conf' do
      is_expected.to contain_neutron_config('DEFAULT/bind_host').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/bind_port').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/auth_strategy').with_value('keystone')
      is_expected.to contain_neutron_config('DEFAULT/core_plugin').with_value( params[:core_plugin] )
      is_expected.to contain_neutron_config('DEFAULT/base_mac').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/mac_generation_retries').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/dhcp_lease_duration').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/host').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/dns_domain').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/dhcp_agents_per_network').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/global_physnet_mtu').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/dhcp_agent_notification').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/allow_bulk').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/allow_overlapping_ips').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/api_extensions_path').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/control_exchange').with_value('neutron')
      is_expected.to contain_neutron_config('DEFAULT/state_path').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_concurrency/lock_path').with_value('$state_path/lock')
      is_expected.to contain_neutron_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/rpc_response_timeout').with_value( '<SERVICE DEFAULT>' )
      is_expected.to contain_neutron_config('agent/root_helper').with_value('sudo neutron-rootwrap /etc/neutron/rootwrap.conf')
      is_expected.to contain_neutron_config('agent/root_helper_daemon').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('agent/report_interval').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'rabbit HA with a single virtual host' do
    it 'in neutron.conf' do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_host').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_port').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_hosts').with_value( params[:rabbit_hosts] )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'rabbit HA with multiple hosts' do
    it 'in neutron.conf' do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_host').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_port').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') )
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(true)
    end
  end

  shared_examples_for 'rabbit with heartbeat configured' do
    it 'in neutron.conf' do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('60')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/heartbeat_rate').with_value('10')
    end
  end

  shared_examples_for 'rabbit with durable queues' do
    it 'in neutron.conf' do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(true)
    end
  end

  shared_examples_for 'rabbit with non default transient_queues_ttl' do
    it 'in neutron.conf' do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_transient_queues_ttl').with_value(20)
    end
  end

  shared_examples_for 'rabbit_ha_queues set to false' do
    it 'in neutron.conf' do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(false)
    end
  end

  shared_examples_for 'notification_driver and notification_topics' do
    it 'in neutron.conf' do
      is_expected.to contain_neutron_config('oslo_messaging_notifications/driver').with_value( params[:notification_driver] )
      is_expected.to contain_neutron_config('oslo_messaging_notifications/topics').with_value( params[:notification_topics] )
      is_expected.to contain_neutron_config('oslo_messaging_notifications/transport_url').with_value( params[:notification_transport_url] )
    end
  end

  shared_examples_for 'with SSL socket options set' do
    before do
      params.merge!(
        :use_ssl         => true,
        :cert_file       => '/path/to/cert',
        :key_file        => '/path/to/key',
        :ca_file         => '/path/to/ca'
      )
    end

    it { is_expected.to contain_neutron_config('DEFAULT/use_ssl').with_value('true') }
    it { is_expected.to contain_neutron_config('ssl/cert_file').with_value('/path/to/cert') }
    it { is_expected.to contain_neutron_config('ssl/key_file').with_value('/path/to/key') }
    it { is_expected.to contain_neutron_config('ssl/ca_file').with_value('/path/to/ca') }
  end

  shared_examples_for 'with SSL socket options set with wrong parameters' do
    before do
      params.merge!(
        :use_ssl         => true,
        :key_file        => '/path/to/key',
        :ca_file         => '/path/to/ca'
      )
    end

    it_raises 'a Puppet::Error', /The cert_file parameter is required when use_ssl is set to true/
  end

  shared_examples_for 'with SSL socket options left by default' do

    it { is_expected.to contain_neutron_config('DEFAULT/use_ssl').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_neutron_config('ssl/cert_file').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_neutron_config('ssl/key_file').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_neutron_config('ssl/ca_file').with_value('<SERVICE DEFAULT>') }
  end

  shared_examples_for 'with SSL socket options set and no ca_file' do
    before do
      params.merge!(
        :use_ssl         => true,
        :cert_file       => '/path/to/cert',
        :key_file        => '/path/to/key'
      )
    end

    it { is_expected.to contain_neutron_config('DEFAULT/use_ssl').with_value('true') }
    it { is_expected.to contain_neutron_config('ssl/cert_file').with_value('/path/to/cert') }
    it { is_expected.to contain_neutron_config('ssl/key_file').with_value('/path/to/key') }
    it { is_expected.to contain_neutron_config('ssl/ca_file').with_ensure('absent') }
  end

  shared_examples_for 'with SSL socket options disabled with ca_file' do
    before do
      params.merge!(
        :use_ssl         => false,
        :ca_file         => '/path/to/ca'
      )
    end

    it_raises 'a Puppet::Error', /The ca_file parameter requires that use_ssl to be set to true/
  end

  shared_examples_for 'with syslog disabled' do
    before do
      params.merge!(
        :use_syslog         => false,
      )
    end
    it { is_expected.to contain_neutron_config('DEFAULT/use_syslog').with_value(false) }
  end

  shared_examples_for 'with non-default kombu options' do
    before do
      params.merge!(
        :kombu_missing_consumer_retry_timeout => '5',
        :kombu_failover_strategy              => 'shuffle',
        :kombu_compression                    => 'gzip',
        :kombu_reconnect_delay                => '30',
      )
    end

    it do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('30')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_missing_consumer_retry_timeout').with_value('5')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('shuffle')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_compression').with_value('gzip')
    end
  end

  shared_examples_for 'with SSL enabled with kombu' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true,
        :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
        :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
        :kombu_ssl_version  => 'TLSv1'
      )
    end

    it do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/path/to/ssl/ca/certs')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/path/to/ssl/cert/file')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/path/to/ssl/keyfile')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
    end
  end

  shared_examples_for 'with SSL enabled without kombu' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true
      )
    end

    it do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'with SSL disabled' do

    it do
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'with SSL and kombu wrongly configured' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true,
        :kombu_ssl_certfile  => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile'
      )
    end

    context 'without required parameters' do

      context 'without kombu_ssl_keyfile parameter' do
        before { params.delete(:kombu_ssl_keyfile) }
        it_raises 'a Puppet::Error', /The kombu_ssl_certfile and kombu_ssl_keyfile parameters must be used together/
      end
    end

  end

  shared_examples_for 'with syslog enabled' do
    before do
      params.merge!(
        :use_syslog => 'true'
      )
    end

    it do
      is_expected.to contain_neutron_config('DEFAULT/use_syslog').with_value(true)
    end
  end

  shared_examples_for 'with log_file specified' do
    before do
      params.merge!(
        :log_file => '/var/log/neutron/server.log',
        :log_dir  => '/tmp/log/neutron'
      )
    end
    it 'configures logging' do
      is_expected.to contain_neutron_config('DEFAULT/log_file').with_value(params[:log_file])
      is_expected.to contain_neutron_config('DEFAULT/log_dir').with_value(params[:log_dir])
    end
  end

  shared_examples_for 'with state and lock paths set' do
    before { params.merge!(
      :state_path => 'state_path',
      :lock_path  => 'lock_path'
    )}
    it {
      is_expected.to contain_neutron_config('DEFAULT/state_path').with_value('state_path')
      is_expected.to contain_neutron_config('oslo_concurrency/lock_path').with_value('lock_path')
    }
  end

  shared_examples_for 'without service_plugins' do
    it { is_expected.not_to contain_neutron_config('DEFAULT/service_plugins') }
  end

  shared_examples_for 'with service_plugins' do
    before do
      params.merge!(
        :service_plugins => ['router','firewall','lbaas','vpnaas','metering','qos']
      )
    end

    it do
      is_expected.to contain_neutron_config('DEFAULT/service_plugins').with_value('router,firewall,lbaas,vpnaas,metering,qos')
    end

  end

  shared_examples_for 'without memcache_servers' do
    it { is_expected.to contain_neutron_config('DEFAULT/memcached_servers').with_ensure('absent') }
  end

  shared_examples_for 'with memcache_servers' do
    before do
      params.merge!(
        :memcache_servers => ['memcache1','memcache2','memcache3']
      )
    end

    it do
      is_expected.to contain_neutron_config('DEFAULT/memcached_servers').with_value('memcache1,memcache2,memcache3')
    end

  end

  shared_examples_for 'with global_physnet_mtu defined' do
    before do
      params.merge!(
        :global_physnet_mtu => 9000
      )
    end

    it do
      is_expected.to contain_neutron_config('DEFAULT/global_physnet_mtu').with_value(params[:global_physnet_mtu])
    end
  end

  shared_examples_for 'with host defined' do
    before do
      params.merge!(
        :host => 'test-001.example.org'
      )
    end

    it do
      is_expected.to contain_neutron_config('DEFAULT/host').with_value(params[:host])
    end
  end

  shared_examples_for 'with dns_domain defined' do
    before do
      params.merge!(
        :dns_domain => 'testlocal'
      )
    end

    it do
      is_expected.to contain_neutron_config('DEFAULT/dns_domain').with_value(params[:dns_domain])
    end
  end

  shared_examples_for 'with transport_url defined' do
    before do
      params.merge!(
        :default_transport_url => 'rabbit://rabbit_user:password@localhost:5673'
      )
    end

    it do
      is_expected.to contain_neutron_config('DEFAULT/transport_url').with_value(params[:default_transport_url])
    end
  end

  shared_examples_for 'with rootwrap daemon' do
    before do
      params.merge!(
        :root_helper_daemon => 'sudo neutron-rootwrap-daemon /etc/neutron/rootwrap.conf'
      )
    end

    it do
      is_expected.to contain_neutron_config('agent/root_helper_daemon').with_value(params[:root_helper_daemon])
    end
  end

  shared_examples_for 'amqp support' do
    context 'with default parameters' do
      before { params.merge!( :rpc_backend => 'amqp' ) }

      it { is_expected.to contain_neutron_config('DEFAULT/rpc_backend').with_value('amqp') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>') }
    end

    context 'with overriden amqp parameters' do
      before { params.merge!(
        :rpc_backend        => 'amqp',
        :amqp_idle_timeout  => '60',
        :amqp_trace         => true,
        :amqp_ssl_ca_file   => '/path/to/ca.cert',
        :amqp_ssl_cert_file => '/path/to/certfile',
        :amqp_ssl_key_file  => '/path/to/key',
        :amqp_username      => 'amqp_user',
        :amqp_password      => 'password',
      ) }

      it { is_expected.to contain_neutron_config('DEFAULT/rpc_backend').with_value('amqp') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/idle_timeout').with_value('60') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/trace').with_value('true') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/ssl_ca_file').with_value('/path/to/ca.cert') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/ssl_cert_file').with_value('/path/to/certfile') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/ssl_key_file').with_value('/path/to/key') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/username').with_value('amqp_user') }
      it { is_expected.to contain_neutron_config('oslo_messaging_amqp/password').with_value('password') }
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian'
      }))
    end

    let :platform_params do
      { :common_package_name => 'neutron-common' }
    end

    it_configures 'neutron'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :platform_params do
      { :common_package_name => 'openstack-neutron' }
    end

    it_configures 'neutron'
  end
end
