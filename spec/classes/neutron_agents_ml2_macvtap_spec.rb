require 'spec_helper'

describe 'neutron::agents::ml2::macvtap' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {}
  end

  shared_examples 'neutron plugin macvtap agent with ml2 plugin' do
    context 'with default parameters' do
      it { should contain_class('neutron::params') }

      it 'passes purge to resource' do
        should contain_resources('neutron_agent_macvtap').with({
          :purge => false
        })
      end

      it 'configures ml2_conf.ini' do
        should contain_neutron_agent_macvtap('agent/polling_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_agent_macvtap('macvtap/physical_interface_mappings').with_ensure('absent')
        should contain_neutron_agent_macvtap('securitygroup/firewall_driver').with_value('noop')
      end

      it 'installs neutron macvtap agent package' do
        should contain_package('neutron-plugin-macvtap-agent').with(
          :name   => platform_params[:macvtap_agent_package],
          :ensure => 'present',
          :tag    => ['openstack', 'neutron-package'],
        )
      end

      it 'configures neutron macvtap agent service' do
        should contain_service('neutron-plugin-macvtap-agent').with(
          :name    => platform_params[:macvtap_agent_service],
          :enable  => true,
          :ensure  => 'running',
          :tag     => 'neutron-service',
        )
        should contain_service('neutron-plugin-macvtap-agent').that_subscribes_to('Anchor[neutron::service::begin]')
        should contain_service('neutron-plugin-macvtap-agent').that_notifies('Anchor[neutron::service::end]')
      end

      context 'with manage_service as false' do
        before :each do
          params.merge!(:manage_service => false)
        end
        it 'should not manage the service' do
          should_not contain_service('neutron-plugin-macvtap-agent')
        end
      end
    end

    context 'when providing the physical_interface_mappings parameter' do
      before do
        params.merge!(:physical_interface_mappings => ['physnet0:eth0', 'physnet1:eth1'])
      end

      it 'configures physical interface mappings' do
        should contain_neutron_agent_macvtap('macvtap/physical_interface_mappings').with_value(
          params[:physical_interface_mappings].join(',')
        )
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
        case facts[:osfamily]
        when 'Debian'
          {
            :macvtap_agent_package => 'neutron-macvtap-agent',
            :macvtap_agent_service => 'neutron-macvtap-agent'
          }
        when 'RedHat'
          {
            :macvtap_agent_package => 'openstack-neutron-macvtap-agent',
            :macvtap_agent_service => 'neutron-macvtap-agent'
          }
        end
      end

      it_behaves_like 'neutron plugin macvtap agent with ml2 plugin'
    end
  end
end
