require 'spec_helper'

describe 'neutron::plugins::ml2::cisco' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :package_ensure => 'present'
    }
  end

  let :params do
    {}
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
      :concat_basedir         => '/',
    }
  end


  shared_examples_for 'neutron plugin cisco ml2' do
    before do
      params.merge!(default_params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'should have' do
      is_expected.to contain_package('python-networking-cisco').with(
        :ensure => params[:package_ensure],
        :tag    => 'openstack'
        )
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

      it_configures 'neutron plugin cisco ml2'
    end
  end
end
