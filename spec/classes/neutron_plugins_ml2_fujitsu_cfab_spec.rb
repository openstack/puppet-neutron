#
# Unit tests for neutron::plugins::ml2::fujitsu::cfab class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::fujitsu::cfab' do

  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :address => '192.168.0.1',
      :username => 'admin',
      :password => 'admin',
      :physical_networks => 'physnet1:1,physnet2:2',
      :share_pprofile => 'false',
      :pprofile_prefix => 'neutron-',
      :save_config => 'true',
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

  shared_examples_for 'neutron fujitsu ml2 cfab plugin' do

    before do
      params.merge!(default_params)
    end

    it do
      is_expected.to contain_neutron_plugin_ml2('fujitsu_cfab/address').with_value(params[:address])
      is_expected.to contain_neutron_plugin_ml2('fujitsu_cfab/username').with_value(params[:username])
      is_expected.to contain_neutron_plugin_ml2('fujitsu_cfab/password').with_value(params[:password])
      is_expected.to contain_neutron_plugin_ml2('fujitsu_cfab/physical_networks').with_value(params[:physical_networks])
      is_expected.to contain_neutron_plugin_ml2('fujitsu_cfab/share_pprofile').with_value(params[:share_pprofile])
      is_expected.to contain_neutron_plugin_ml2('fujitsu_cfab/pprofile_prefix').with_value(params[:pprofile_prefix])
      is_expected.to contain_neutron_plugin_ml2('fujitsu_cfab/save_config').with_value(params[:save_config])
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'neutron fujitsu ml2 cfab plugin'
    end
  end
end
