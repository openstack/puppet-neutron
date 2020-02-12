require 'spec_helper'

describe 'neutron::server' do
  let :pre_condition do
    "class { 'neutron': }
     class { '::neutron::keystone::authtoken':
       password => 'passw0rd',
     }"
  end

  let :params do
    {}
  end

  let :default_params do
    {
      :package_ensure           => 'present',
      :enabled                  => true,
      :auth_strategy            => 'keystone',
      :database_connection      => 'sqlite:////var/lib/neutron/ovs.sqlite',
      :database_max_retries     => 10,
      :database_idle_timeout    => 3600,
      :database_retry_interval  => 10,
      :database_min_pool_size   => 1,
      :database_max_pool_size   => 10,
      :database_max_overflow    => 20,
      :sync_db                  => false,
      :router_scheduler_driver  => 'neutron.scheduler.l3_agent_scheduler.ChanceScheduler',
      :l3_ha                    => false,
      :max_l3_agents_per_router => 3,
    }
  end

  shared_examples 'a neutron server' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::db') }
    it { should contain_class('neutron::params') }
    it { should contain_class('neutron::policy') }

    it 'installs neutron server package' do
      if platform_params.has_key?(:server_package)
        should contain_package('neutron-server').with(
          :name   => platform_params[:server_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        should contain_package('neutron-server').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron-server').that_notifies('Anchor[neutron::install::end]')
      else
        should contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    it 'configures neutron server service' do
      should contain_service('neutron-server').with(
        :name    => platform_params[:server_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => ['neutron-service', 'neutron-db-sync-service', 'neutron-server-eventlet'],
      )
      should contain_service('neutron-server').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-server').that_notifies('Anchor[neutron::service::end]')
      should_not contain_class('neutron::db::sync')
      should contain_service('neutron-server').with_name('neutron-server')
      should contain_neutron_config('DEFAULT/api_workers').with_value(facts[:os_workers])
      should contain_neutron_config('DEFAULT/rpc_workers').with_value(facts[:os_workers])
      should contain_neutron_config('DEFAULT/rpc_response_max_timeout').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/agent_down_time').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/enable_new_agents').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('DEFAULT/router_scheduler_driver').with_value(p[:router_scheduler_driver])
      should contain_oslo__middleware('neutron_config').with(
        :enable_proxy_headers_parsing => '<SERVICE DEFAULT>',
        :max_request_body_size        => '<SERVICE DEFAULT>',
      )
      should contain_neutron_config('DEFAULT/ovs_integration_bridge').with_value('<SERVICE DEFAULT>')
      should contain_neutron_config('ovs/igmp_snooping_enable').with_value('<SERVICE DEFAULT>')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end

      it 'should not start/stop service' do
        should contain_service('neutron-server').without_ensure
      end
    end

    context 'with DVR enabled for new routers' do
      before :each do
        params.merge!(:router_distributed => true)
      end

      it 'should enable DVR for new routers' do
        should contain_neutron_config('DEFAULT/router_distributed').with_value(true)
      end
    end

    context 'with DVR disabled' do
      before :each do
        params.merge!(:enable_dvr => false)
      end

      it 'should disable DVR' do
        should contain_neutron_config('DEFAULT/enable_dvr').with_value(false)
      end
    end

    context 'with HA routers enabled' do
      before :each do
        params.merge!(:l3_ha => true)
      end

      it 'should enable HA routers' do
        should contain_neutron_config('DEFAULT/l3_ha').with_value(true)
        should contain_neutron_config('DEFAULT/max_l3_agents_per_router').with_value(3)
        should contain_neutron_config('DEFAULT/l3_ha_net_cidr').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with HA routers disabled' do
      before :each do
        params.merge!(:l3_ha => false)
      end

      it 'should disable HA routers' do
        should contain_neutron_config('DEFAULT/l3_ha').with_value(false)
        should contain_neutron_config('DEFAULT/max_l3_agents_per_router').with_value(3)
        should contain_neutron_config('DEFAULT/l3_ha_net_cidr').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with HA routers enabled with unlimited l3 agents per router' do
      before :each do
        params.merge!(:l3_ha                    => true,
                      :max_l3_agents_per_router => 0 )
      end

      it 'should enable HA routers' do
        should contain_neutron_config('DEFAULT/max_l3_agents_per_router').with_value(0)
      end
    end

    context 'with allow_automatic_l3agent_failover in neutron.conf' do
      it 'should configure allow_automatic_l3agent_failover' do
        should contain_neutron_config('DEFAULT/allow_automatic_l3agent_failover').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with allow_automatic_dhcp_failover in neutron.conf' do
      it 'should configure allow_automatic_dhcp_failover' do
        should contain_neutron_config('DEFAULT/allow_automatic_dhcp_failover').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with network_auto_schedule in neutron.conf' do
      it 'should configure network_auto_schedule' do
        should contain_neutron_config('DEFAULT/network_auto_schedule').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with a bad dhcp_load_type value' do
      before :each do
        params.merge!(:dhcp_load_type => 'badvalue')
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'with multiple service providers' do
      before :each do
        params.merge!(
          { :service_providers => ['provider1', 'provider2'] }
        )
      end

      it 'configures neutron.conf' do
        should contain_neutron_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
      end
    end

    context 'with availability zone hints set' do
      before :each do
        params.merge!( :dhcp_load_type             => 'networks',
                       :router_scheduler_driver    => 'neutron.scheduler.l3_agent_scheduler.AZLeastRoutersScheduler',
                       :network_scheduler_driver   => 'neutron.scheduler.dhcp_agent_scheduler.AZAwareWeightScheduler',
                       :default_availability_zones => ['zone1', 'zone2']
        )
      end

      it 'should configure neutron server for availability zones' do
        should contain_neutron_config('DEFAULT/default_availability_zones').with_value('zone1,zone2')
        should contain_neutron_config('DEFAULT/router_scheduler_driver').with_value('neutron.scheduler.l3_agent_scheduler.AZLeastRoutersScheduler')
        should contain_neutron_config('DEFAULT/network_scheduler_driver').with_value('neutron.scheduler.dhcp_agent_scheduler.AZAwareWeightScheduler')
        should contain_neutron_config('DEFAULT/dhcp_load_type').with_value('networks')
      end

    end

    context 'with enable_proxy_headers_parsing' do
      before :each do
        params.merge!( :enable_proxy_headers_parsing => true )
      end

      it { should contain_oslo__middleware('neutron_config').with(
        :enable_proxy_headers_parsing => true,
      )}
    end

    context 'with max_request_body_size' do
      before :each do
        params.merge!( :max_request_body_size => '102400' )
      end

      it { should contain_oslo__middleware('neutron_config').with(
        :max_request_body_size => '102400',
      )}
    end

    context 'when running neutron-api in wsgi' do
      before :each do
        params.merge!( :service_name => 'httpd' )
      end

      let :pre_condition do
        "class { 'neutron': }
         include ::apache
         class { '::neutron::keystone::authtoken':
           password => 'passw0rd',
         }"
      end

      it 'configures neutron-api service with Apache' do
        should contain_service('neutron-server').with(
          :ensure     => 'stopped',
          :name       => platform_params[:server_service],
          :enable     => false,
          :tag        => ['neutron-service', 'neutron-db-sync-service'],
        )
      end
    end

    context 'when service_name is customized' do
      before :each do
        params.merge!({ :service_name => 'foobar' })
      end

      it 'configures neutron-api service with custom name' do
        should contain_service('neutron-server').with(
          :name    => 'foobar',
          :enable  => true,
          :ensure  => 'running',
          :tag     => ['neutron-service', 'neutron-db-sync-service'],
        )
      end
    end

    context 'with ovs_integration_bridge set' do
      before :each do
        params.merge!({:ovs_integration_bridge => 'br-int' })
      end

      it { should contain_neutron_config('DEFAULT/ovs_integration_bridge').with_value('br-int') }
    end

    context 'with IGMP snooping enabled' do
      before :each do
        params.merge!(:igmp_snooping_enable => true)
      end

      it 'configure neutron.conf' do
        should contain_neutron_config('ovs/igmp_snooping_enable').with_value(true)
      end
    end

  end

  shared_examples 'VPNaaS and FWaaS package installation' do
    before do
      params.merge!(
        :ensure_vpnaas_package => true,
        :ensure_fwaas_package  => true,
      )
    end

    it 'should install *aaS packages' do
      should contain_package('neutron-fwaas')
      should contain_package('neutron-vpnaas-agent')
    end
  end

  shared_examples 'neutron server dynamic routing on Debian' do
    before do
      params.merge!( :ensure_dr_package => true )
    end

    it 'should install dynamic routing package' do
      should contain_package('neutron-dynamic-routing')
      should_not contain_package('neutron-bgp-dragent')
    end
  end

  shared_examples 'neutron server dynamic routing on RedHat' do
    before do
      params.merge!( :ensure_dr_package => true )
    end

    it 'should install bgp dragent package' do
      should_not contain_package('neutron-dynamic-routing')
      should contain_package('neutron-bgp-dragent')
    end
  end

  shared_examples 'a neutron server without database synchronization' do
    before do
      params.merge!(
        :sync_db => true
      )
    end

    it 'includes neutron::db::sync' do
      should contain_class('neutron::db::sync')
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
            :server_package => 'neutron-server',
            :server_service => 'neutron-server'
          }
        when 'RedHat'
          {
            :server_service => 'neutron-server'
          }
        end
      end

      it_behaves_like 'a neutron server'
      it_behaves_like 'a neutron server without database synchronization'
      it_behaves_like "neutron server dynamic routing on #{facts[:osfamily]}"
    end
  end
end
