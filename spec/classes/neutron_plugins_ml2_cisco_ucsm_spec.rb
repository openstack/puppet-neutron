#
# Unit tests for neutron::plugins::ml2::cisco::ucsm class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::ucsm' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :ucsm_ip => '1.1.1.1',
      :ucsm_username => 'admin',
      :ucsm_password => 'password',
      :ucsm_host_list => 'host1:profile1, host2:profile2',
      :supported_pci_devs => [ '2222:3333', '4444:5555' ]
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

  shared_examples_for 'neutron cisco ml2 ucsm plugin' do

    before do
      params.merge!(default_params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it do
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_ucsm/ucsm_ip').with_value(params[:ucsm_ip])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_ucsm/ucsm_username').with_value(params[:ucsm_username])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_ucsm/ucsm_password').with_value(params[:ucsm_password])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_ucsm/ucsm_host_list').with_value(params[:ucsm_host_list])
      is_expected.to contain_neutron_plugin_ml2('ml2_cisco_ucsm/supported_pci_devs').with_value(params[:supported_pci_devs])
    end

  end

  begin
    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily => 'RedHat',
           :operatingsystemrelease => '7',
        }))
      end

      it_configures 'neutron cisco ml2 ucsm plugin'
    end
  end
end
