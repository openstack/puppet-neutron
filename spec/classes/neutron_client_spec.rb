require 'spec_helper'

describe 'neutron::client' do

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it { is_expected.to contain_class('neutron::client') }
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it { is_expected.to contain_class('neutron::client') }
  end
end
