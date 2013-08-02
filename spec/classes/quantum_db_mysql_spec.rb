require 'spec_helper'

describe 'quantum::db::mysql' do

  let :pre_condition do
    'include mysql::server'
  end

  let :params do
    { :password => 'passw0rd' }
  end
  let :facts do
      { :osfamily => 'Debian' }
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

  describe "overriding allowed_hosts param to array" do
    let :params do
      {
        :password       => 'quantumpass',
        :allowed_hosts  => ['127.0.0.1','%']
      }
    end

    it {should_not contain_quantum__db__mysql__host_access("127.0.0.1").with(
      :user     => 'quantum',
      :password => 'quantumpass',
      :database => 'quantum'
    )}
    it {should contain_quantum__db__mysql__host_access("%").with(
      :user     => 'quantum',
      :password => 'quantumpass',
      :database => 'quantum'
    )}
  end

  describe "overriding allowed_hosts param to string" do
    let :params do
      {
        :password       => 'quantumpass2',
        :allowed_hosts  => '192.168.1.1'
      }
    end

    it {should contain_quantum__db__mysql__host_access("192.168.1.1").with(
      :user     => 'quantum',
      :password => 'quantumpass2',
      :database => 'quantum'
    )}
  end

  describe "overriding allowed_hosts param equals to host param " do
    let :params do
      {
        :password       => 'quantumpass2',
        :allowed_hosts  => '127.0.0.1'
      }
    end

    it {should_not contain_quantum__db__mysql__host_access("127.0.0.1").with(
      :user     => 'quantum',
      :password => 'quantumpass2',
      :database => 'quantum'
    )}
  end
end

