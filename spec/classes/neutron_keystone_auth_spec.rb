require 'spec_helper'

describe 'neutron::keystone::auth' do
  shared_examples 'neutron::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        {
          :password => 'neutron_password',
          :tenant   => 'foobar'
        }
      end

      it { should contain_keystone_user('neutron').with(
        :ensure   => 'present',
        :password => 'neutron_password',
      )}

      it { should contain_keystone_user_role('neutron@foobar').with(
        :ensure  => 'present',
        :roles   => ['admin']
      )}

      it { should contain_keystone_service('neutron::network').with(
        :ensure      => 'present',
        :description => 'Neutron Networking Service'
      )}

      it { should contain_keystone_endpoint('RegionOne/neutron::network').with(
        :ensure       => 'present',
        :public_url   => "http://127.0.0.1:9696",
        :admin_url    => "http://127.0.0.1:9696",
        :internal_url => "http://127.0.0.1:9696"
      )}
    end

    context 'when configuring neutron-server' do
      let :pre_condition do
        "class { '::neutron::keystone::authtoken':
          password => 'test',
         }
         class { 'neutron::server': }"
      end

      let :params do
        {
          :password => 'neutron_password',
          :tenant   => 'foobar'
        }
      end

    end

    context 'with endpoint URL parameters' do
      let :params do
        {
          :password     => 'neutron_password',
          :public_url   => 'https://10.10.10.10:80',
          :internal_url => 'https://10.10.10.11:81',
          :admin_url    => 'https://10.10.10.12:81'
        }
      end

      it { should contain_keystone_endpoint('RegionOne/neutron::network').with(
        :ensure       => 'present',
        :public_url   => 'https://10.10.10.10:80',
        :internal_url => 'https://10.10.10.11:81',
        :admin_url    => 'https://10.10.10.12:81'
      ) }
    end

    context 'when overriding auth name' do  
      let :params do
        {
          :password  => 'foo',
          :auth_name => 'neutrony'
        }
      end

      it { should contain_keystone_user('neutrony') } 
      it { should contain_keystone_user_role('neutrony@services') } 
      it { should contain_keystone_service('neutron::network') }
      it { should contain_keystone_endpoint('RegionOne/neutron::network') }
    end

    context 'when overriding service name' do
      let :params do
        {
          :service_name => 'neutron_service',
          :password     => 'neutron_password'
        }
      end

      it { should contain_keystone_user('neutron') }
      it { should contain_keystone_user_role('neutron@services') }
      it { should contain_keystone_service('neutron_service::network') }
      it { should contain_keystone_endpoint('RegionOne/neutron_service::network') }
    end

    context 'when disabling user configuration' do
      let :params do
        {
          :password       => 'neutron_password',
          :configure_user => false
        }
      end

      it { should_not contain_keystone_user('neutron') }
      it { should contain_keystone_user_role('neutron@services') }

      it { should contain_keystone_service('neutron::network').with(
        :ensure      => 'present',
        :description => 'Neutron Networking Service'
      )}
    end

    context 'when disabling user and user role configuration' do  
      let :params do
        {
          :password            => 'neutron_password',
          :configure_user      => false,
          :configure_user_role => false
        }
      end

      it { should_not contain_keystone_user('neutron') }
      it { should_not contain_keystone_user_role('neutron@services') }

      it { should contain_keystone_service('neutron::network').with(
        :ensure      => 'present',
        :description => 'Neutron Networking Service'
      )}
    end

    context 'when disabling endpoint configuration' do
      let :params do
        {
          :password           => 'neutron_password',
          :configure_endpoint => false
        }
      end

      it { should_not contain_keystone_endpoint('RegionOne/neutron::network') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::keystone::auth'
    end
  end
end
