require 'spec_helper'

describe 'quantum::db::mysql::host_access' do

  let :pre_condition do
    'include mysql'
  end

  let :title do
    '127.0.0.1'
  end

  let :params do
    { :user     => 'quantum',
      :password => 'passw0rd',
      :database => 'quantum' }
  end

  let :facts do
    { :osfamily => 'Debian' }
  end

  it { should contain_database_user('quantum@127.0.0.1') }
  it { should contain_database_grant('quantum@127.0.0.1/quantum') }
end
