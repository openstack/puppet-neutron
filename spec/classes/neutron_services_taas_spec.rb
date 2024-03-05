require 'spec_helper'

describe 'neutron::services::taas' do

  shared_examples 'neutron taas service plugin' do
    context 'with default params' do
      it 'installs taas package' do
        should contain_package('neutron-taas').with(
          :ensure => 'installed',
          :name   => platform_params[:taas_package_name]
        )
      end

      it 'configures taas_plugin.ini' do
        should contain_neutron_taas_service_config(
          'service_providers/service_provider'
        ).with_value(
          'TAAS:TAAS:neutron_taas.services.taas.service_drivers.taas_rpc.TaasRpcDriver:default'
        )
        should contain_neutron_taas_service_config('quotas/quota_tap_service').with_value('<SERVICE DEFAULT>')
        should contain_neutron_taas_service_config('quotas/quota_tap_flow').with_value('<SERVICE DEFAULT>')
      end

      it 'does not run neutron-db-manage' do
        should_not contain_exec('taas-db-sync')
      end
    end

    context 'with parameters' do
      let :params do
        {
          :quota_tap_service => 1,
          :quota_tap_flow    => 10,
        }
      end
      it 'configures taas_plugin.ini' do
        should contain_neutron_taas_service_config('quotas/quota_tap_service').with_value(1)
        should contain_neutron_taas_service_config('quotas/quota_tap_flow').with_value(10)
      end
    end

    context 'with db sync enabled' do
      let :params do
        {
          :sync_db => true
        }
      end

      it 'runs neutron-db-manage' do
        should contain_exec('taas-db-sync').with(
          :command     => 'neutron-db-manage --subproject tap-as-a-service upgrade head',
          :path        => '/usr/bin',
          :user        => 'neutron',
          :subscribe   => ['Anchor[neutron::install::end]',
                           'Anchor[neutron::config::end]',
                           'Anchor[neutron::dbsync::begin]'
                           ],
          :notify      => 'Anchor[neutron::dbsync::end]',
          :refreshonly => 'true',
        )
      end
    end

    context 'with multiple service providers' do
      let :params do
        {
          :service_providers => ['provider1', 'provider2']
        }
      end

      it 'configures taas_plugin.ini' do
        should contain_neutron_taas_service_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :taas_package_name => 'python3-neutron-taas' }
        when 'RedHat'
          { :taas_package_name => 'python3-tap-as-a-service' }
        end
      end
      it_behaves_like 'neutron taas service plugin'
    end
  end
end
