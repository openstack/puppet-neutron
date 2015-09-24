require 'spec_helper'

describe 'neutron::db' do

  shared_examples 'neutron::db' do

    context 'with default parameters' do

      it { is_expected.to contain_neutron_config('database/connection').with_value('sqlite:////var/lib/neutron/ovs.sqlite').with_secret(true) }
      it { is_expected.to contain_neutron_config('database/idle_timeout').with_value('3600') }
      it { is_expected.to contain_neutron_config('database/min_pool_size').with_value('1') }
      it { is_expected.to contain_neutron_config('database/max_retries').with_value('10') }
      it { is_expected.to contain_neutron_config('database/retry_interval').with_value('10') }

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql://neutron:neutron@localhost/neutron',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_retries    => '11',
          :database_retry_interval => '11', }
      end

      it { is_expected.to contain_neutron_config('database/connection').with_value('mysql://neutron:neutron@localhost/neutron').with_secret(true) }
      it { is_expected.to contain_neutron_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_neutron_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_neutron_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_neutron_config('database/retry_interval').with_value('11') }

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'redis://neutron:neutron@localhost/neutron', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'neutron::db'
  end

  context 'on Redhat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'neutron::db'
  end

end
