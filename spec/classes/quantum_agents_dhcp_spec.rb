require 'spec_helper'

describe 'quantum::agents::dhcp' do

  let :pre_condition do
    "class { 'quantum': rabbit_password => 'passw0rd' }"
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it { should contain_class('quantum::agents::dhcp') }
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it { should contain_class('quantum::agents::dhcp') }
  end
end
