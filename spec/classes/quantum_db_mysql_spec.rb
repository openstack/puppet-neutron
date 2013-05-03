require 'spec_helper'

describe 'quantum::db::mysql' do

  let :pre_condition do
    'include mysql::server'
  end

  let :params do
    { :password => 'passw0rd' }
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it { should contain_class('quantum::db::mysql') }
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it { should contain_class('quantum::db::mysql') }
  end
end
