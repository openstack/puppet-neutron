require 'spec_helper'

describe 'neutron::keystone::auth' do

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  describe 'with default class parameters' do
    let :params do
      {
        :password => 'neutron_password',
        :tenant   => 'foobar'
      }
    end

    it { is_expected.to contain_keystone_user('neutron').with(
      :ensure   => 'present',
      :password => 'neutron_password',
    ) }

    it { is_expected.to contain_keystone_user_role('neutron@foobar').with(
      :ensure  => 'present',
      :roles   => ['admin']
    )}

    it { is_expected.to contain_keystone_service('neutron::network').with(
      :ensure      => 'present',
      :description => 'Neutron Networking Service'
    ) }

    it { is_expected.to contain_keystone_endpoint('RegionOne/neutron::network').with(
      :ensure       => 'present',
      :public_url   => "http://127.0.0.1:9696",
      :admin_url    => "http://127.0.0.1:9696",
      :internal_url => "http://127.0.0.1:9696"
    ) }

  end

  describe 'when configuring neutron-server' do
    let :pre_condition do
      "class { 'neutron::server': password => 'test' }"
    end

    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian'
      }))
    end

    let :params do
      {
        :password => 'neutron_password',
        :tenant   => 'foobar'
      }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/neutron::network').with_notify(['Service[neutron-server]']) }
  end

  describe 'with endpoint URL parameters' do
    let :params do
      {
        :password     => 'neutron_password',
        :public_url   => 'https://10.10.10.10:80',
        :internal_url => 'https://10.10.10.11:81',
        :admin_url    => 'https://10.10.10.12:81'
      }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/neutron::network').with(
      :ensure       => 'present',
      :public_url   => 'https://10.10.10.10:80',
      :internal_url => 'https://10.10.10.11:81',
      :admin_url    => 'https://10.10.10.12:81'
    ) }
  end

  describe 'when overriding auth name' do

    let :params do
      {
        :password => 'foo',
        :auth_name => 'neutrony'
      }
    end

    it { is_expected.to contain_keystone_user('neutrony') }

    it { is_expected.to contain_keystone_user_role('neutrony@services') }

    it { is_expected.to contain_keystone_service('neutron::network') }

    it { is_expected.to contain_keystone_endpoint('RegionOne/neutron::network') }

  end

  describe 'when overriding service name' do

    let :params do
      {
        :service_name => 'neutron_service',
        :password     => 'neutron_password'
      }
    end

    it { is_expected.to contain_keystone_user('neutron') }
    it { is_expected.to contain_keystone_user_role('neutron@services') }
    it { is_expected.to contain_keystone_service('neutron_service::network') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/neutron_service::network') }

  end

  describe 'when disabling user configuration' do

    let :params do
      {
        :password       => 'neutron_password',
        :configure_user => false
      }
    end

    it { is_expected.not_to contain_keystone_user('neutron') }

    it { is_expected.to contain_keystone_user_role('neutron@services') }

    it { is_expected.to contain_keystone_service('neutron::network').with(
      :ensure      => 'present',
      :description => 'Neutron Networking Service'
    ) }

  end

  describe 'when disabling user and user role configuration' do

    let :params do
      {
        :password            => 'neutron_password',
        :configure_user      => false,
        :configure_user_role => false
      }
    end

    it { is_expected.not_to contain_keystone_user('neutron') }

    it { is_expected.not_to contain_keystone_user_role('neutron@services') }

    it { is_expected.to contain_keystone_service('neutron::network').with(
      :ensure      => 'present',
      :description => 'Neutron Networking Service'
    ) }

  end

  describe 'when disabling endpoint configuration' do

    let :params do
      {
        :password           => 'neutron_password',
        :configure_endpoint => false
      }
    end

    it { is_expected.to_not contain_keystone_endpoint('RegionOne/neutron::network') }

  end

end
