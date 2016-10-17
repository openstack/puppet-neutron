require 'spec_helper'

describe 'neutron::server' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :params do
    { :password            => 'passw0rd',
      :username            => 'neutron',
      :keystone_auth_type  => 'password',
      :project_domain_name => 'Default',
      :project_name        => 'services',
      :user_domain_name    => 'Default'}
  end

  let :default_params do
    { :package_ensure                   => 'present',
      :enabled                          => true,
      :auth_type                        => 'keystone',
      :database_connection              => 'sqlite:////var/lib/neutron/ovs.sqlite',
      :database_max_retries             => 10,
      :database_idle_timeout            => 3600,
      :database_retry_interval          => 10,
      :database_min_pool_size           => 1,
      :database_max_pool_size           => 10,
      :database_max_overflow            => 20,
      :sync_db                          => false,
      :router_scheduler_driver          => 'neutron.scheduler.l3_agent_scheduler.ChanceScheduler',
      :l3_ha                            => false,
      :max_l3_agents_per_router         => 3,
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'a neutron server' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::db') }
    it { is_expected.to contain_class('neutron::params') }
    it { is_expected.to contain_class('neutron::policy') }

    it 'installs neutron server package' do
      if platform_params.has_key?(:server_package)
        is_expected.to contain_package('neutron-server').with(
          :name   => platform_params[:server_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        is_expected.to contain_package('neutron-server').that_requires('Anchor[neutron::install::begin]')
        is_expected.to contain_package('neutron-server').that_notifies('Anchor[neutron::install::end]')
      else
        is_expected.to contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        is_expected.to contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    it 'configures neutron server service' do
      is_expected.to contain_service('neutron-server').with(
        :name    => platform_params[:server_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => ['neutron-service', 'neutron-db-sync-service'],
      )
      is_expected.to contain_service('neutron-server').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('neutron-server').that_notifies('Anchor[neutron::service::end]')
      is_expected.not_to contain_class('neutron::db::sync')
      is_expected.to contain_service('neutron-server').with_name('neutron-server')
      is_expected.to contain_neutron_config('DEFAULT/api_workers').with_value(facts[:processorcount])
      is_expected.to contain_neutron_config('DEFAULT/rpc_workers').with_value(facts[:processorcount])
      is_expected.to contain_neutron_config('DEFAULT/agent_down_time').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/router_scheduler_driver').with_value(p[:router_scheduler_driver])
      is_expected.to contain_neutron_config('qos/notification_drivers').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('oslo_middleware/enable_proxy_headers_parsing').with_value('<SERVICE DEFAULT>')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        is_expected.to contain_service('neutron-server').without_ensure
      end
    end

    context 'with DVR enabled' do
      before :each do
        params.merge!(:router_distributed => true)
      end
      it 'should enable DVR' do
        is_expected.to contain_neutron_config('DEFAULT/router_distributed').with_value(true)
      end
    end

    context 'with HA routers enabled' do
      before :each do
        params.merge!(:l3_ha => true)
      end
      it 'should enable HA routers' do
        is_expected.to contain_neutron_config('DEFAULT/l3_ha').with_value(true)
        is_expected.to contain_neutron_config('DEFAULT/max_l3_agents_per_router').with_value(3)
        is_expected.to contain_neutron_config('DEFAULT/l3_ha_net_cidr').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with HA routers disabled' do
      before :each do
        params.merge!(:l3_ha => false)
      end
      it 'should disable HA routers' do
        is_expected.to contain_neutron_config('DEFAULT/l3_ha').with_value(false)
        is_expected.to contain_neutron_config('DEFAULT/max_l3_agents_per_router').with_value(3)
        is_expected.to contain_neutron_config('DEFAULT/l3_ha_net_cidr').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with HA routers enabled with unlimited l3 agents per router' do
      before :each do
        params.merge!(:l3_ha                    => true,
                      :max_l3_agents_per_router => 0 )
      end
      it 'should enable HA routers' do
        is_expected.to contain_neutron_config('DEFAULT/max_l3_agents_per_router').with_value(0)
      end
    end

    context 'with custom service name' do
      before :each do
        params.merge!(:service_name => 'custom-service-name')
      end
      it 'should configure proper service name' do
        is_expected.to contain_service('neutron-server').with_name('custom-service-name')
      end
    end

    context 'with state_path and lock_path parameters' do
      before :each do
        params.merge!(:state_path => 'state_path',
                      :lock_path  => 'lock_path' )
      end
      it 'should override state_path and lock_path from base class' do
        is_expected.to contain_neutron_config('DEFAULT/state_path').with_value(p[:state_path])
        is_expected.to contain_neutron_config('oslo_concurrency/lock_path').with_value(p[:lock_path])
      end
    end

    context 'with allow_automatic_l3agent_failover in neutron.conf' do
      it 'should configure allow_automatic_l3agent_failover' do
        is_expected.to contain_neutron_config('DEFAULT/allow_automatic_l3agent_failover').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with allow_automatic_dhcp_failover in neutron.conf' do
      it 'should configure allow_automatic_dhcp_failover' do
        is_expected.to contain_neutron_config('DEFAULT/allow_automatic_dhcp_failover').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with qos_notification_drivers parameter' do
      before :each do
        params.merge!(:qos_notification_drivers => 'message_queue')
      end
      it 'should configure qos_notification_drivers' do
        is_expected.to contain_neutron_config('qos/notification_drivers').with_value('message_queue')
      end
    end

    context 'with network_auto_schedule in neutron.conf' do
      it 'should configure network_auto_schedule' do
        is_expected.to contain_neutron_config('DEFAULT/network_auto_schedule').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with a bad dhcp_load_type value' do
      before :each do
        params.merge!(:dhcp_load_type => 'badvalue')
      end

      it_raises 'a Puppet::Error', /Must pass either networks, subnets, or ports as values for dhcp_load_type/
    end

    context 'with multiple service providers' do
      before :each do
        params.merge!(
          { :service_providers => ['provider1', 'provider2'] }
        )
      end

      it 'configures neutron.conf' do
        is_expected.to contain_neutron_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
      end
    end

    context 'with availability zone hints set' do
      before :each do
        params.merge!(:dhcp_load_type             => 'networks',
                      :router_scheduler_driver    => 'neutron.scheduler.l3_agent_scheduler.AZLeastRoutersScheduler',
                      :network_scheduler_driver   => 'neutron.scheduler.dhcp_agent_scheduler.AZAwareWeightScheduler',
                      :default_availability_zones => ['zone1', 'zone2']
        )
      end

      it 'should configure neutron server for availability zones' do
        is_expected.to contain_neutron_config('DEFAULT/default_availability_zones').with_value('zone1,zone2')
        is_expected.to contain_neutron_config('DEFAULT/router_scheduler_driver').with_value('neutron.scheduler.l3_agent_scheduler.AZLeastRoutersScheduler')
        is_expected.to contain_neutron_config('DEFAULT/network_scheduler_driver').with_value('neutron.scheduler.dhcp_agent_scheduler.AZAwareWeightScheduler')
        is_expected.to contain_neutron_config('DEFAULT/dhcp_load_type').with_value('networks')
      end

    end

    context 'with enable_proxy_headers_parsing' do
      before :each do
        params.merge!({:enable_proxy_headers_parsing => true })
      end

      it { is_expected.to contain_neutron_config('oslo_middleware/enable_proxy_headers_parsing').with_value(true) }
    end
  end

  shared_examples_for 'a neutron server with broken authentication' do
    before do
      params.delete(:password)
    end
    it_raises 'a Puppet::Error', /Please set password for neutron service user/
  end

  shared_examples_for 'VPNaaS, FWaaS and LBaaS package installation' do
    before do
      params.merge!(
        :ensure_vpnaas_package => true,
        :ensure_fwaas_package  => true,
        :ensure_lbaas_package  => true
      )
    end
    it 'should install *aaS packages' do
      is_expected.to contain_package('neutron-lbaasv2-agent')
      is_expected.to contain_package('neutron-fwaas')
      is_expected.to contain_package('neutron-vpnaas-agent')
    end
  end

  shared_examples_for 'a neutron server without database synchronization' do
    before do
      params.merge!(
        :sync_db => true
      )
    end
    it 'includes neutron::db::sync' do
      is_expected.to contain_class('neutron::db::sync')
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian',
         :processorcount => '2'
      }))
    end

    let :platform_params do
      { :server_package => 'neutron-server',
        :server_service => 'neutron-server' }
    end

    it_configures 'a neutron server'
    it_configures 'a neutron server with broken authentication'
    it_configures 'a neutron server without database synchronization'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :processorcount         => '2'
      }))
    end

    let :platform_params do
      { :server_service => 'neutron-server' }
    end

    it_configures 'a neutron server'
    it_configures 'a neutron server with broken authentication'
    it_configures 'a neutron server without database synchronization'
  end
end
