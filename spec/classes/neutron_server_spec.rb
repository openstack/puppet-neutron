require 'spec_helper'

describe 'neutron::server' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :params do
    { :password    => 'passw0rd',
      :username    => 'neutron',
      :tenant_name => 'services' }
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
      :min_l3_agents_per_router         => 2,
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

    it 'configures authentication middleware' do
      is_expected.to contain_neutron_config('keystone_authtoken/tenant_name').with_value(p[:tenant_name]);
      is_expected.to contain_neutron_config('keystone_authtoken/username').with_value(p[:username]);
      is_expected.to contain_neutron_config('keystone_authtoken/password').with_value(p[:password]);
      is_expected.to contain_neutron_config('keystone_authtoken/password').with_secret( true )
      is_expected.to contain_neutron_config('keystone_authtoken/auth_uri').with_value("http://localhost:5000/");
      is_expected.to contain_neutron_config('keystone_authtoken/auth_url').with_value("http://localhost:35357/");
      is_expected.to contain_neutron_config('keystone_authtoken/project_domain_id').with_value("<SERVICE DEFAULT>");
      is_expected.to contain_neutron_config('keystone_authtoken/project_name').with_value("<SERVICE DEFAULT>");
      is_expected.to contain_neutron_config('keystone_authtoken/user_domain_id').with_value("<SERVICE DEFAULT>");
      is_expected.not_to contain_neutron_config('keystone_authtoken/admin_tenant_name');
      is_expected.not_to contain_neutron_config('keystone_authtoken/admin_user');
      is_expected.not_to contain_neutron_config('keystone_authtoken/admin_password');
      is_expected.not_to contain_neutron_config('keystone_authtoken/identity_uri');
    end

    it 'installs neutron server package' do
      if platform_params.has_key?(:server_package)
        is_expected.to contain_package('neutron-server').with(
          :name   => platform_params[:server_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        is_expected.to contain_package('neutron-server').with_before(/Neutron_api_config\[.+\]/)
        is_expected.to contain_package('neutron-server').with_before(/Neutron_config\[.+\]/)
        is_expected.to contain_package('neutron-server').with_before(/Service\[neutron-server\]/)
      else
        is_expected.to contain_package('neutron').with_before(/Neutron_api_config\[.+\]/)
      end
    end

    it 'configures neutron server service' do
      is_expected.to contain_service('neutron-server').with(
        :name    => platform_params[:server_service],
        :enable  => true,
        :ensure  => 'running',
        :require => 'Class[Neutron]',
        :tag     => ['neutron-service', 'neutron-db-sync-service'],
      )
      is_expected.not_to contain_class('neutron::db::sync')
      is_expected.to contain_service('neutron-server').with_name('neutron-server')
      is_expected.to contain_neutron_config('DEFAULT/api_workers').with_value(facts[:processorcount])
      is_expected.to contain_neutron_config('DEFAULT/rpc_workers').with_value(facts[:processorcount])
      is_expected.to contain_neutron_config('DEFAULT/agent_down_time').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/router_scheduler_driver').with_value(p[:router_scheduler_driver])
      is_expected.to contain_neutron_config('qos/notification_drivers').with_value('<SERVICE DEFAULT>')
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
        is_expected.to contain_neutron_config('DEFAULT/min_l3_agents_per_router').with_value(2)
        is_expected.to contain_neutron_config('DEFAULT/l3_ha_net_cidr').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with HA routers disabled' do
      before :each do
        params.merge!(:l3_ha => false)
      end
      it 'should disable HA routers' do
        is_expected.to contain_neutron_config('DEFAULT/l3_ha').with_value(false)
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

    context 'with HA routers enabled and wrong parameters' do
      before :each do
        params.merge!(:l3_ha                    => true,
                      :max_l3_agents_per_router => 2,
                      :min_l3_agents_per_router => 3 )
      end

      it_raises 'a Puppet::Error', /min_l3_agents_per_router should be less than or equal to max_l3_agents_per_router./
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
        is_expected.to contain_neutron_config('DEFAULT/lock_path').with_value(p[:lock_path])
      end
    end

    context 'with allow_automatic_l3agent_failover in neutron.conf' do
      it 'should configure allow_automatic_l3agent_failover' do
        is_expected.to contain_neutron_config('DEFAULT/allow_automatic_l3agent_failover').with_value('<SERVICE DEFAULT>')
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
  end

  shared_examples_for 'a neutron server with broken authentication' do
    before do
      params.delete(:password)
    end
    it_raises 'a Puppet::Error', /Either auth_password or password must be set when using keystone authentication/
  end

  shared_examples_for 'a neutron server with incompatible authentication params' do
    before do
      params.merge!(
        :auth_password => "passw0rd"
      )
    end
    it_raises 'a Puppet::Error', /auth_password and password must not be used together/
  end

  shared_examples_for 'a neutron server with deprecated authentication params' do
    before do
      params.merge!(
        :auth_user     => "neutron",
        :auth_password => "passw0rd",
        :auth_tenant   => "services",
        :auth_region   => "MyRegion",
        :identity_uri  => "https://foo.bar:5000/"
      )
      params.delete(:password)
    end
    it 'configures authentication middleware' do
      is_expected.to contain_neutron_api_config('filter:authtoken/admin_tenant_name').with_value('services');
      is_expected.to contain_neutron_api_config('filter:authtoken/admin_user').with_value('neutron');
      is_expected.to contain_neutron_api_config('filter:authtoken/admin_password').with_value('passw0rd');
      is_expected.to contain_neutron_api_config('filter:authtoken/admin_password').with_secret( true )
      is_expected.to contain_neutron_api_config('filter:authtoken/identity_uri').with_value('https://foo.bar:5000/');
      is_expected.to contain_neutron_config('keystone_authtoken/admin_tenant_name').with_value('services');
      is_expected.to contain_neutron_config('keystone_authtoken/admin_user').with_value('neutron');
      is_expected.to contain_neutron_config('keystone_authtoken/admin_password').with_value('passw0rd');
      is_expected.to contain_neutron_config('keystone_authtoken/admin_password').with_secret( true )
      is_expected.to contain_neutron_config('keystone_authtoken/identity_uri').with_value('https://foo.bar:5000/');
      is_expected.to contain_neutron_config('keystone_authtoken/auth_region').with_value('MyRegion');
      is_expected.not_to contain_neutron_config('keystone_authtoken/tenant_name');
      is_expected.not_to contain_neutron_config('keystone_authtoken/username');
      is_expected.not_to contain_neutron_config('keystone_authtoken/password');
      is_expected.not_to contain_neutron_config('keystone_authtoken/auth_url');
    end
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
      is_expected.to contain_package('neutron-lbaas-agent')
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

  describe "with custom keystone authentication params" do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end
    before do
      params.merge!({
        :auth_uri          => 'https://foo.bar:5000/',
        :auth_url          => 'https://foo.bar:35357/v3',
        :auth_plugin       => 'v3password',
        :project_domain_id => 'default',
        :project_name      => 'services',
        :user_domain_id    => 'default'
      })
    end
    it 'configures keystone authentication params' do
      is_expected.to contain_neutron_config('keystone_authtoken/auth_uri').with_value("https://foo.bar:5000/");
      is_expected.to contain_neutron_config('keystone_authtoken/auth_url').with_value("https://foo.bar:35357/v3");
      is_expected.to contain_neutron_config('keystone_authtoken/project_domain_id').with_value("default");
      is_expected.to contain_neutron_config('keystone_authtoken/project_name').with_value("services");
      is_expected.to contain_neutron_config('keystone_authtoken/user_domain_id').with_value("default");
    end
  end

  describe "with custom auth region" do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end
    before do
      params.merge!({
        :region_name => 'MyRegion',
      })
    end
    it 'configures region_name' do
      is_expected.to contain_neutron_config('keystone_authtoken/region_name').with_value('MyRegion');
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
    it_configures 'a neutron server with incompatible authentication params'
    it_configures 'a neutron server with deprecated authentication params'
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
    it_configures 'a neutron server with incompatible authentication params'
    it_configures 'a neutron server with deprecated authentication params'
    it_configures 'a neutron server without database synchronization'
  end
end
