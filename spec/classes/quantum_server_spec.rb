require 'spec_helper'

describe 'quantum::server' do

  let :params do
    { :auth_password => 'passw0rd' }
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it { should contain_class('quantum::server') }
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it { should contain_class('quantum::server') }
  end
end
