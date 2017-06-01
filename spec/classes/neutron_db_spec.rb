require 'spec_helper'

describe 'neutron::db' do

  shared_examples 'neutron::db' do

    context 'with default parameters' do

      it { is_expected.to contain_oslo__db('neutron_config').with(
        :db_max_retries => '<SERVICE DEFAULT>',
        :connection     => 'sqlite:////var/lib/neutron/ovs.sqlite',
        :idle_timeout   => '<SERVICE DEFAULT>',
        :min_pool_size  => '<SERVICE DEFAULT>',
        :max_pool_size  => '<SERVICE DEFAULT>',
        :max_retries    => '<SERVICE DEFAULT>',
        :retry_interval => '<SERVICE DEFAULT>',
        :max_overflow   => '<SERVICE DEFAULT>',
      )}

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql+pymysql://neutron:neutron@localhost/neutron',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '11',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_db_max_retries => '-1',
          :database_max_overflow   => '21',
        }
      end

      it { is_expected.to contain_oslo__db('neutron_config').with(
        :db_max_retries => '-1',
        :connection     => 'mysql+pymysql://neutron:neutron@localhost/neutron',
        :idle_timeout   => '3601',
        :min_pool_size  => '2',
        :max_pool_size  => '11',
        :max_retries    => '11',
        :retry_interval => '11',
        :max_overflow   => '21',
      )}

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection => 'mysql://neutron:neutron@localhost/neutron' }
      end

      it { is_expected.to contain_oslo__db('neutron_config').with(
        :connection => 'mysql://neutron:neutron@localhost/neutron',
      )}
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection => 'postgresql://neutron:neutron@localhost/neutron', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'redis://neutron:neutron@localhost/neutron', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'foo+pymysql://neutron:neutron@localhost/neutron', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
         :osfamily => 'Debian',
         :operatingsystem => 'Debian',
         :operatingsystemrelease => 'jessie',
      })
    end

    it_configures 'neutron::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://neutron:neutron@localhost/neutron' }
      end

      it { is_expected.to contain_package('python-pymysql').with({ :ensure => 'present', :name => 'python-pymysql' }) }
    end

  end

  context 'on Redhat platforms' do
    let :facts do
      @default_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7.1',
      })
    end

    it_configures 'neutron::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://neutron:neutron@localhost/neutron' }
      end

    end

  end

end
