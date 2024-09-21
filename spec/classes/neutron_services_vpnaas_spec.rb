require 'spec_helper'

describe 'neutron::services::vpnaas' do

  shared_examples 'neutron vpnaas service plugin' do
    context 'with default params' do
      it 'installs vpnaas package' do
        should contain_package('neutron-vpnaas-agent').with(
          :ensure => 'installed',
          :name   => platform_params[:vpnaas_agent_package_name]
        )
      end

      it 'configures neutron_vpnaas.conf' do
        should contain_neutron_vpnaas_service_config(
          'service_providers/service_provider'
        ).with_value(
          'VPN:openswan:neutron_vpnaas.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default'
        )
        should contain_neutron_vpnaas_service_config('DEFAULT/vpn_scheduler_driver').with_value('<SERVICE DEFAULT>')
        should contain_neutron_vpnaas_service_config('DEFAULT/vpn_auto_schedule').with_value('<SERVICE DEFAULT>')
        should contain_neutron_vpnaas_service_config('DEFAULT/allow_automatic_vpnagent_failover').with_value('<SERVICE DEFAULT>')
      end

      it 'does not run neutron-db-manage' do
        should_not contain_exec('vpnaas-db-sync')
      end
    end

    context 'with db sync enabled' do
      let :params do
        {
          :sync_db => true
        }
      end

      it 'runs neutron-db-manage' do
        should contain_exec('vpnaas-db-sync').with(
          :command     => 'neutron-db-manage --subproject neutron-vpnaas upgrade head',
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

      it 'configures neutron_vpnaas.conf' do
        should contain_neutron_vpnaas_service_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
      end
    end

    context 'with parameters' do
      let :params do
        {
          :vpn_scheduler_driver              => 'neutron_vpnaas.scheduler.vpn_agent_scheduler.LeastRoutersScheduler',
          :vpn_auto_schedule                 => true,
          :allow_automatic_vpnagent_failover => false,
        }
      end

      it 'configures neutron_vpnaas.conf' do
        should contain_neutron_vpnaas_service_config('DEFAULT/vpn_scheduler_driver').with_value(
          'neutron_vpnaas.scheduler.vpn_agent_scheduler.LeastRoutersScheduler'
        )
        should contain_neutron_vpnaas_service_config('DEFAULT/vpn_auto_schedule').with_value(true)
        should contain_neutron_vpnaas_service_config('DEFAULT/allow_automatic_vpnagent_failover').with_value(false)
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
          { :vpnaas_agent_package_name => 'python3-neutron-vpnaas' }
        when 'RedHat'
          { :vpnaas_agent_package_name => 'openstack-neutron-vpnaas' }
        end
      end
      it_behaves_like 'neutron vpnaas service plugin'
    end
  end
end
