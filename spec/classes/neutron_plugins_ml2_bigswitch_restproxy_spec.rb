#
# Unit tests for neutron::plugins::ml2::cisco::nexus class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::bigswitch::restproxy' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
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

  let :test_facts do
    { :operatingsystem         => 'default',
      :operatingsystemrelease  => 'default',
    }
  end

  shared_examples_for 'neutron bigswitch ml2 restproxy' do

    it { is_expected.to contain_class('neutron::params') }
    it { is_expected.to contain_class('neutron::plugins::ml2::bigswitch') }

    it do
      is_expected.to contain_neutron_plugin_ml2('restproxy/servers').with_value(params[:servers])
      is_expected.to contain_neutron_plugin_ml2('restproxy/server_auth').with_value(params[:server_auth])

      is_expected.to contain_neutron_plugin_ml2('restproxy/auto_sync_on_failure').with_value(true)
      is_expected.to contain_neutron_plugin_ml2('restproxy/consistency_interval').with_value(60)
      is_expected.to contain_neutron_plugin_ml2('restproxy/neutron_id').with_value('neutron')
      is_expected.to contain_neutron_plugin_ml2('restproxy/server_ssl').with_value(true)
      is_expected.to contain_neutron_plugin_ml2('restproxy/ssl_cert_directory').with_value('/var/lib/neutron')

      is_expected.to contain_neutron_plugin_ml2('restproxy/auth_tenant').with_value('service')
      is_expected.to contain_neutron_plugin_ml2('restproxy/auth_password').with_value(false)
      is_expected.to contain_neutron_plugin_ml2('restproxy/auth_user').with_value('neutron')
      is_expected.to contain_neutron_plugin_ml2('restproxy/auth_url').with_value(false)
    end

    context 'with custom params' do
      let :params do
        required_params.merge({
          :auto_sync_on_failure => false,
          :consistency_interval => 10,
          :neutron_id           => 'openstack',
          :server_ssl           => false,
          :ssl_cert_directory   => '/var/lib/bigswitch',
        })
      end

      it do
        is_expected.to contain_neutron_plugin_ml2('restproxy/auto_sync_on_failure').with_value(false)
        is_expected.to contain_neutron_plugin_ml2('restproxy/consistency_interval').with_value(10)
        is_expected.to contain_neutron_plugin_ml2('restproxy/neutron_id').with_value('openstack')
        is_expected.to contain_neutron_plugin_ml2('restproxy/server_ssl').with_value(false)
        is_expected.to contain_neutron_plugin_ml2('restproxy/ssl_cert_directory').with_value('/var/lib/bigswitch')

        is_expected.to contain_neutron_plugin_ml2('restproxy/auth_tenant').with_value('service')
        is_expected.to contain_neutron_plugin_ml2('restproxy/auth_password').with_value(false)
        is_expected.to contain_neutron_plugin_ml2('restproxy/auth_user').with_value('neutron')
        is_expected.to contain_neutron_plugin_ml2('restproxy/auth_url').with_value(false)
      end
    end

  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    it_configures 'neutron bigswitch ml2 restproxy'
  end
end
