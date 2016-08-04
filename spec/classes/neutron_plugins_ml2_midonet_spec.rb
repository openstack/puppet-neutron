#
# Unit tests for neutron::plugins::ml2::midonet class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::midonet' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :midonet_uri  => 'http://localhost:8080/midonet-api',
      :username     => 'admin',
      :password     => 'passw0rd',
      :project_id   => 'admin',
    }
  end

  let :params do
    {}
  end

  let :test_facts do
    { :operatingsystem         => 'default',
      :operatingsystemrelease  => 'default',
      :concat_basedir          => '/',
    }
  end

  shared_examples_for 'neutron ml2 midonet plugin' do

    before do
      params.merge!(default_params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it do
      is_expected.to contain_neutron_plugin_ml2('MIDONET/midonet_uri').with_value(params[:midonet_uri])
      is_expected.to contain_neutron_plugin_ml2('MIDONET/username').with_value(params[:username])
      is_expected.to contain_neutron_plugin_ml2('MIDONET/password').with_value(params[:password])
      is_expected.to contain_neutron_plugin_ml2('MIDONET/project_id').with_value(params[:project_id])
    end

  end

  begin
    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily               => 'RedHat',
           :operatingsystemrelease => '7'
        }))
      end

      let :platform_params do
        { :midonet_ml2_config_file => '/etc/neutron/conf.d/neutron-server/ml2_mech_midonet.conf' }
      end

      it_configures 'neutron ml2 midonet plugin'
    end
  end
end
