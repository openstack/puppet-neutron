#
# Unit tests for neutron::keystone::auth
#

require 'spec_helper'

describe 'neutron::keystone::auth' do
  shared_examples_for 'neutron::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'neutron_password' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('neutron').with(
        :configure_user      => true,
        :configure_user_role => true,
        :configure_endpoint  => true,
        :service_name        => 'neutron',
        :service_type        => 'network',
        :service_description => 'OpenStack Networking Service',
        :region              => 'RegionOne',
        :auth_name           => 'neutron',
        :password            => 'neutron_password',
        :email               => 'neutron@localhost',
        :tenant              => 'services',
        :public_url          => 'http://127.0.0.1:9696',
        :internal_url        => 'http://127.0.0.1:9696',
        :admin_url           => 'http://127.0.0.1:9696',
      ) }
    end

    context 'when overriding parameters' do
      let :params do
        { :password            => 'neutron_password',
          :auth_name           => 'alt_neutron',
          :email               => 'alt_neutron@alt_localhost',
          :tenant              => 'alt_service',
          :configure_endpoint  => false,
          :configure_user      => false,
          :configure_user_role => false,
          :service_description => 'Alternative OpenStack Networking Service',
          :service_name        => 'alt_service',
          :service_type        => 'alt_network',
          :region              => 'RegionTwo',
          :public_url          => 'https://10.10.10.10:80',
          :internal_url        => 'http://10.10.10.11:81',
          :admin_url           => 'http://10.10.10.12:81' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('neutron').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => false,
        :service_name        => 'alt_service',
        :service_type        => 'alt_network',
        :service_description => 'Alternative OpenStack Networking Service',
        :region              => 'RegionTwo',
        :auth_name           => 'alt_neutron',
        :password            => 'neutron_password',
        :email               => 'alt_neutron@alt_localhost',
        :tenant              => 'alt_service',
        :public_url          => 'https://10.10.10.10:80',
        :internal_url        => 'http://10.10.10.11:81',
        :admin_url           => 'http://10.10.10.12:81',
      ) }
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
