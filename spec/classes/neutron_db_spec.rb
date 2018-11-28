require 'spec_helper'

describe 'neutron::db' do
  shared_examples 'neutron::db' do
    context 'with default parameters' do
      it { should contain_oslo__db('neutron_config').with(
        :db_max_retries => '<SERVICE DEFAULT>',
        :connection     => 'sqlite:////var/lib/neutron/ovs.sqlite',
        :idle_timeout   => '<SERVICE DEFAULT>',
        :min_pool_size  => '<SERVICE DEFAULT>',
        :max_pool_size  => '<SERVICE DEFAULT>',
        :max_retries    => '<SERVICE DEFAULT>',
        :retry_interval => '<SERVICE DEFAULT>',
        :max_overflow   => '<SERVICE DEFAULT>',
        :pool_timeout   => '<SERVICE DEFAULT>',
      )}

    end

    context 'with specific parameters' do
      let :params do
        {
          :database_connection     => 'mysql+pymysql://neutron:neutron@localhost/neutron',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '11',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_db_max_retries => '-1',
          :database_max_overflow   => '21',
          :database_pool_timeout   => '21',
        }
      end

      it { should contain_oslo__db('neutron_config').with(
        :db_max_retries => '-1',
        :connection     => 'mysql+pymysql://neutron:neutron@localhost/neutron',
        :idle_timeout   => '3601',
        :min_pool_size  => '2',
        :max_pool_size  => '11',
        :max_retries    => '11',
        :retry_interval => '11',
        :max_overflow   => '21',
        :pool_timeout   => '21',
      )}

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection => 'mysql+pymysql://neutron:neutron@localhost/neutron' }
      end

      it { should contain_oslo__db('neutron_config').with(
        :connection => 'mysql+pymysql://neutron:neutron@localhost/neutron',
      )}
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection => 'postgresql://neutron:neutron@localhost/neutron', }
      end

      it 'install the proper backend package' do
        should contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'redis://neutron:neutron@localhost/neutron', }
      end

      it { should raise_error(Puppet::Error, /validate_re/) }
    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'foo+pymysql://neutron:neutron@localhost/neutron', }
      end

      it { should raise_error(Puppet::Error, /validate_re/) }
    end

  end

  shared_examples 'neutron::db on Debian' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://neutron:neutron@localhost/neutron' }
      end

      it { should contain_package('python-pymysql').with({ :ensure => 'present', :name => 'python-pymysql' }) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::db'

      if facts[:osfamily] == 'Debian'
        it_behaves_like 'neutron::db on Debian'
      end
    end
  end
end
