require 'spec_helper'

describe 'neutron::plugins::ml2::bigswitch::restproxy' do
  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2'
     }"
  end

  let :required_params do
    {
      :servers     => '192.168.0.10:8000,192.168.0.11:8000',
      :server_auth => 'admin:password',
    }
  end

  let :params do
    required_params
  end

  shared_examples 'neutron bigswitch ml2 restproxy' do

    it { should contain_class('neutron::params') }
    it { should contain_class('neutron::plugins::ml2::bigswitch') }

    it do
      should contain_neutron_plugin_ml2('restproxy/servers').with_value(params[:servers])
      should contain_neutron_plugin_ml2('restproxy/server_auth').with_value(params[:server_auth])
      should contain_neutron_plugin_ml2('restproxy/auth_tenant').with_value('service')
      should contain_neutron_plugin_ml2('restproxy/auth_password').with_value(false)
      should contain_neutron_plugin_ml2('restproxy/auth_user').with_value('neutron')
      should contain_neutron_plugin_ml2('restproxy/auth_url').with_value(false)
      should contain_neutron_plugin_ml2('restproxy/auto_sync_on_failure').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/cache_connections').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/consistency_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/keystone_sync_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/neutron_id').with_value('neutron')
      should contain_neutron_plugin_ml2('restproxy/no_ssl_validation').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/server_ssl').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/server_timeout').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/ssl_cert_directory').with_value('/var/lib/neutron')
      should contain_neutron_plugin_ml2('restproxy/sync_data').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('restproxy/thread_pool_size').with_value('<SERVICE DEFAULT>')

    end

    context 'with custom params' do
      let :params do
        required_params.merge({
          :auto_sync_on_failure   => false,
          :cache_connections      => true,
          :consistency_interval   => 10,
          :keystone_sync_interval => 10,
          :neutron_id             => 'openstack',
          :no_ssl_validation      => true,
          :server_ssl             => false,
          :server_timeout         => 30,
          :ssl_cert_directory     => '/var/lib/bigswitch',
          :sync_data              => true,
          :thread_pool_size       => 8,
        })
      end

      it do

        should contain_neutron_plugin_ml2('restproxy/servers').with_value(params[:servers])
        should contain_neutron_plugin_ml2('restproxy/server_auth').with_value(params[:server_auth])
        should contain_neutron_plugin_ml2('restproxy/auth_tenant').with_value('service')
        should contain_neutron_plugin_ml2('restproxy/auth_password').with_value(false)
        should contain_neutron_plugin_ml2('restproxy/auth_user').with_value('neutron')
        should contain_neutron_plugin_ml2('restproxy/auth_url').with_value(false)
        should contain_neutron_plugin_ml2('restproxy/auto_sync_on_failure').with_value(false)
        should contain_neutron_plugin_ml2('restproxy/cache_connections').with_value(true)
        should contain_neutron_plugin_ml2('restproxy/consistency_interval').with_value(10)
        should contain_neutron_plugin_ml2('restproxy/keystone_sync_interval').with_value(10)
        should contain_neutron_plugin_ml2('restproxy/neutron_id').with_value('openstack')
        should contain_neutron_plugin_ml2('restproxy/no_ssl_validation').with_value(true)
        should contain_neutron_plugin_ml2('restproxy/server_ssl').with_value(false)
        should contain_neutron_plugin_ml2('restproxy/server_timeout').with_value(30)
        should contain_neutron_plugin_ml2('restproxy/ssl_cert_directory').with_value('/var/lib/bigswitch')
        should contain_neutron_plugin_ml2('restproxy/sync_data').with_value(true)
        should contain_neutron_plugin_ml2('restproxy/thread_pool_size').with_value(8)
      end
    end

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'neutron bigswitch ml2 restproxy'
      end
    end
  end
end
