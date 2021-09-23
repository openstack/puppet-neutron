require 'spec_helper'

describe 'neutron::agents::bigswitch' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  shared_examples 'neutron::agents::bigswitch' do
    context 'neutron bigswitch base' do
      it 'should have' do
        should contain_package('python3-networking-bigswitch').with(
          :ensure => 'installed',
          :tag    => ['openstack', 'neutron-package'],
        )
      end
    end

    context 'neutron-bsn-agent only' do
      let :params do
        {
          :lldp_enabled   => false,
          :agent_enabled  => true
        }
      end

      it 'enable neutron-bsn-agent service' do
        should contain_service('bigswitch-agent').with(
          :enable => params[:agent_enabled],
          :ensure =>'running',
          :tag    =>'neutron-service',
        )
      end

      it 'disable neutron-bsn-lldp service' do
        should contain_service('bigswitch-lldp').with(
          :enable => params[:lldp_enabled],
          :ensure =>'stopped',
          :tag    =>'neutron-service',
        )
      end

    end

    context 'neutron-bsn-lldp only' do
      let :params do
        {
          :lldp_enabled  => true,
          :agent_enabled => false
        }
      end

      it 'disable neutron-bsn-agent service' do
        should contain_service('bigswitch-agent').with(
          :enable => params[:agent_enabled],
          :ensure =>'stopped',
          :tag    =>'neutron-service',
        )
      end

      it 'enable neutron-bsn-lldp service' do
        should contain_service('bigswitch-lldp').with(
          :enable => params[:lldp_enabled],
          :ensure =>'running',
          :tag    =>'neutron-service',
        )
      end
    end
  end

  shared_examples 'neutron::agents::bigswitch on Debian' do
    it { should raise_error(Puppet::Error, /Unsupported osfamily Debian/) }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      if facts[:osfamily] == 'Debian'
        it_behaves_like 'neutron::agents::bigswitch on Debian'
      else
        it_behaves_like 'neutron::agents::bigswitch'
      end
    end
  end
end
