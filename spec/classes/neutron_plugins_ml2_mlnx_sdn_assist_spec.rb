require 'spec_helper'

describe 'neutron::plugins::ml2::mellanox::mlnx_sdn_assist' do

  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2' }"
  end

  let :default_params do
    {
      :sdn_url                 => '<SERVICE DEFAULT>',
    }
  end

  let :params do
    {
      :sdn_username           => 'user',
      :sdn_password           => 'password',
    }
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
    }
  end


  shared_examples_for 'neutron plugin mellanox ml2 mlnx_sdn_assist' do
    before do
      params.merge!(default_params)
    end

    it 'configures sdn settings' do
      is_expected.to contain_neutron_plugin_ml2('sdn/password').with_value(params[:sdn_password]).with_secret(true)
      is_expected.to contain_neutron_plugin_ml2('sdn/username').with_value(params[:sdn_username])
      is_expected.to contain_neutron_plugin_ml2('sdn/url').with_value(params[:sdn_url])
    end

  end


  context 'on RedHat platforms' do
    let :facts do
      OSDefaults.get_facts.merge(test_facts.merge({
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7'
      }))
    end

    it_configures 'neutron plugin mellanox ml2 mlnx_sdn_assist'
  end

  context 'on Debian platforms' do
    let :facts do
      OSDefaults.get_facts.merge(test_facts.merge({
          :osfamily               => 'Debian',
      }))
    end

    it_configures 'neutron plugin mellanox ml2 mlnx_sdn_assist'
  end
end
