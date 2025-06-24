require 'spec_helper'

describe 'neutron::agents::fwaas' do
  let :params do
    {}
  end

  shared_examples 'neutron::agents::fwaas' do
    context 'with defaults' do
      it { should contain_class('neutron::params') }

      it 'configures fwaas_driver.ini' do
        should contain_neutron_fwaas_agent_config('fwaas/driver').with_value('<SERVICE DEFAULT>')
        should contain_neutron_fwaas_agent_config('fwaas/enabled').with_value('<SERVICE DEFAULT>')
        should contain_neutron_fwaas_agent_config('fwaas/conntrack_driver').with_value('<SERVICE DEFAULT>')
        should contain_neutron_fwaas_agent_config('fwaas/firewall_l2_driver').with_value('<SERVICE DEFAULT>')
      end
      it 'configures ml2_conf.ini' do
        should contain_neutron_plugin_ml2('fwaas/driver').with_value('<SERVICE DEFAULT>')
        should contain_neutron_plugin_ml2('fwaas/enabled').with_value('<SERVICE DEFAULT>')
        should contain_neutron_plugin_ml2('fwaas/conntrack_driver').with_value('<SERVICE DEFAULT>')
        should contain_neutron_plugin_ml2('fwaas/firewall_l2_driver').with_value('<SERVICE DEFAULT>')
      end

      it 'installs neutron fwaas package' do
        should contain_package('neutron-fwaas').with(
          :ensure => 'installed',
          :name   => platform_params[:fwaas_package],
          :tag    => ['openstack', 'neutron-package'],
        )
      end
    end

    context 'with parameters' do
      let :params do
        {
          :driver             => 'iptables_v2',
          :enabled            => true,
          :conntrack_driver   => 'conntrack',
          :firewall_l2_driver => 'ovs',
        }
      end

      it 'configures fwaas_driver.ini' do
        should contain_neutron_fwaas_agent_config('fwaas/driver').with_value('iptables_v2')
        should contain_neutron_fwaas_agent_config('fwaas/enabled').with_value(true)
        should contain_neutron_fwaas_agent_config('fwaas/conntrack_driver').with_value('conntrack')
        should contain_neutron_fwaas_agent_config('fwaas/firewall_l2_driver').with_value('ovs')
      end
      it 'configures ml2_conf.ini' do
        should contain_neutron_plugin_ml2('fwaas/driver').with_value('iptables_v2')
        should contain_neutron_plugin_ml2('fwaas/enabled').with_value(true)
        should contain_neutron_plugin_ml2('fwaas/conntrack_driver').with_value('conntrack')
        should contain_neutron_plugin_ml2('fwaas/firewall_l2_driver').with_value('ovs')
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
          {
            :fwaas_package => 'python3-neutron-fwaas'
          }
        when 'RedHat'
          {
            :fwaas_package => 'openstack-neutron-fwaas'
          }
        end
      end

      it_behaves_like 'neutron::agents::fwaas'
    end
  end
end
