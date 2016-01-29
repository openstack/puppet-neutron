require 'spec_helper'

describe 'neutron::agents::bigswitch' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
      :package_ensure         => 'present',
    }
  end

  shared_examples_for 'neutron bigswitch base' do
    it 'should have' do
      is_expected.to contain_package('python-networking-bigswitch').with(
        :ensure => 'present',
        :tag    => 'openstack'
      )
    end
  end

  context 'neutron-bsn-agent only' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :params do
      {
        :lldp_enabled   => false,
        :agent_enabled  => true
      }
    end

    it_configures 'neutron bigswitch base'

    it 'enable neutron-bsn-agent service' do
      is_expected.to contain_service('bigswitch-agent').with(
        :enable => params[:agent_enabled],
        :ensure =>'running',
        :tag    =>'neutron-service',
      )
    end

    it 'disable neutron-bsn-lldp service' do
      is_expected.to contain_service('bigswitch-lldp').with(
        :enable => params[:lldp_enabled],
        :ensure =>'stopped',
        :tag    =>'neutron-service',
      )
    end

  end

  context 'neutron-bsn-lldp only' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :params do
      {
        :lldp_enabled  => true,
        :agent_enabled => false
      }
    end

    it_configures 'neutron bigswitch base'

    it 'disable neutron-bsn-agent service' do
      is_expected.to contain_service('bigswitch-agent').with(
        :enable => params[:agent_enabled],
        :ensure =>'stopped',
        :tag    =>'neutron-service',
      )
    end

    it 'enable neutron-bsn-lldp service' do
      is_expected.to contain_service('bigswitch-lldp').with(
        :enable => params[:lldp_enabled],
        :ensure =>'running',
        :tag    =>'neutron-service',
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian'
      }))
    end

    let :params do
      {
        :lldp_enabled  => false,
        :agent_enabled => false
      }
    end

    it { is_expected.to raise_error(Puppet::Error, /Unsupported osfamily Debian/) }

  end

end
