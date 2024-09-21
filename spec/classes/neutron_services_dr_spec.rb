require 'spec_helper'

describe 'neutron::services::dr' do

  shared_examples 'neutron dr service plugin' do
    context 'with default params' do
      it 'installs dr package' do
        should contain_package('neutron-dynamic-routing').with(
          :ensure => 'installed',
          :name   => platform_params[:dynamic_routing_package],
          :tag    => ['openstack', 'neutron-package'],
        )
      end

      it 'configures neutron.conf' do
        should contain_neutron_config('DEFAULT/bgp_drscheduler_driver').with_value('<SERVICE DEFAULT>')
      end

      it 'does not run neutron-db-manage' do
        should_not contain_exec('dr-db-sync')
      end
    end

    context 'with db sync enabled' do
      let :params do
        {
          :sync_db => true
        }
      end

      it 'runs neutron-db-manage' do
        should contain_exec('dr-db-sync').with(
          :command     => 'neutron-db-manage --subproject neutron-dynamic-routing upgrade head',
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
          {
            :dynamic_routing_package => 'python3-neutron-dynamic-routing',
          }
        when 'RedHat'
          {
            :dynamic_routing_package => 'python3-neutron-dynamic-routing',
          }
        end
      end

      it_behaves_like 'neutron dr service plugin'
    end
  end
end
