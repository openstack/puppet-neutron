require 'spec_helper'

describe 'neutron::services::fwaas' do

  shared_examples 'neutron fwaas service plugin' do
    context 'with default params' do
      it 'installs fwaas package' do
        should contain_package('neutron-fwaas').with(
          :ensure => 'installed',
          :name   => platform_params[:fwaas_package_name]
        )
      end

      it 'configures neutron_fwaas.conf' do
        should contain_neutron_fwaas_service_config(
          'service_providers/service_provider'
        ).with_value(
          'FIREWALL_V2:fwaas_db:neutron_fwaas.services.firewall.service_drivers.agents.agents.FirewallAgentDriver:default'
        )
      end

      it 'does not run neutron-db-manage' do
        should_not contain_exec('fwaas-db-sync')
      end
    end

    context 'with db sync enabled' do
      let :params do
        {
          :sync_db => true
        }
      end

      it 'runs neutron-db-manage' do
        should contain_exec('fwaas-db-sync').with(
          :command     => 'neutron-db-manage --subproject neutron-fwaas upgrade head',
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

      it 'configures neutron_fwaas.conf' do
        should contain_neutron_fwaas_service_config(
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
          { :fwaas_package_name => 'python3-neutron-fwaas' }
        when 'RedHat'
          { :fwaas_package_name => 'openstack-neutron-fwaas' }
        end
      end
      it_behaves_like 'neutron fwaas service plugin'
    end
  end
end
