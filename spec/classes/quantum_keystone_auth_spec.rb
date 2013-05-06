require 'spec_helper'

describe 'quantum::keystone::auth' do

  describe 'with default class parameters' do
    let :params do
      {
        :password => 'quantum_password',
        :tenant   => 'foobar'
      }
    end

    it { should contain_keystone_user('quantum').with(
      :ensure   => 'present',
      :password => 'quantum_password',
      :tenant   => 'foobar'
    ) }

    it { should contain_keystone_user_role('quantum@foobar').with(
      :ensure  => 'present',
      :roles   => 'admin'
    )}

    it { should contain_keystone_service('quantum').with(
      :ensure      => 'present',
      :type        => 'network',
      :description => 'Quantum Networking Service'
    ) }

    it { should contain_keystone_endpoint('RegionOne/quantum').with(
      :ensure       => 'present',
      :public_url   => "http://127.0.0.1:9696/",
      :admin_url    => "http://127.0.0.1:9696/",
      :internal_url => "http://127.0.0.1:9696/"
    ) }

  end

  describe 'when overriding public_protocol, public_port and public address' do

    let :params do
      {
        :password         => 'quantum_password',
        :public_protocol  => 'https',
        :public_port      => '80',
        :public_address   => '10.10.10.10',
        :port             => '81',
        :internal_address => '10.10.10.11',
        :admin_address    => '10.10.10.12'
      }
    end

    it { should contain_keystone_endpoint('RegionOne/quantum').with(
      :ensure       => 'present',
      :public_url   => "https://10.10.10.10:80/",
      :internal_url => "http://10.10.10.11:81/",
      :admin_url    => "http://10.10.10.12:81/"
    ) }

  end

  describe 'when overriding auth name' do

    let :params do
      {
        :password => 'foo',
        :auth_name => 'quantumy'
      }
    end

    it { should contain_keystone_user('quantumy') }

    it { should contain_keystone_user_role('quantumy@services') }

    it { should contain_keystone_service('quantumy') }

    it { should contain_keystone_endpoint('RegionOne/quantumy') }

  end

end
