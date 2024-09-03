require 'spec_helper'

describe 'neutron::plugins::ml2::ovn::maintenance_worker' do

  shared_examples 'neutron::plugins::ml2::ovn::maintenance_worker' do
    it { should contain_class('neutron::params') }

    it 'should install OVN maintenance worker' do
      should contain_package('neutron-ovn-maintenance-worker').with(
        :ensure  => 'present',
        :name    => platform_params[:ovn_maintenance_worker_package],
        :tag     => ['openstack', 'neutron-package'],
      )
    end

    it 'configures OVN maintenance worker' do
      should contain_service('neutron-ovn-maintenance-worker').with(
        :name    => platform_params[:ovn_maintenance_worker_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
    end

    context 'with manage_service as false' do
      let :params do
        { :manage_service => false }
      end

      it 'should not manage the service' do
        should_not contain_service('neutron-ovn-maintenance-worker')
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          {}
        when 'RedHat'
          { :ovn_maintenance_worker_package => 'openstack-neutron-ovn-maintenance-worker',
            :ovn_maintenance_worker_service => 'neutron-ovn-maintenance-worker' }
        end
      end

      if facts[:os]['family'] == 'RedHat'
        it_behaves_like 'neutron::plugins::ml2::ovn::maintenance_worker'
      end
    end
  end
end
