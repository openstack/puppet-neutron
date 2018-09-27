require 'spec_helper'

describe 'neutron::plugins::ml2::bigswitch' do

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
    }
  end


  shared_examples_for 'neutron plugin bigswitch ml2' do
    before do
      params.merge!(default_params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'should have' do
      is_expected.to contain_package('python-networking-bigswitch').with(
        :ensure => params[:package_ensure],
        :tag    => 'openstack'
        )
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7',
         :os       => { :name  => 'CentOS', :family => 'RedHat', :release => { :major => '7', :minor => '0' } },
      }))
    end

    it_configures 'neutron plugin bigswitch ml2'
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian',
         :os       => { :name  => 'Debian', :family => 'Debian', :release => { :major => '8', :minor => '0' } },
      }))
    end

    it { is_expected.to raise_error(Puppet::Error, /Unsupported osfamily Debian/) }
  end
end
