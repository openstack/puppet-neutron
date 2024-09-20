#
# Unit tests for neutron::agents::vpnaas::ovn class
#
require 'spec_helper'

describe 'neutron::agents::vpnaas::ovn' do
  let :params do
    {}
  end

  shared_examples 'neutron::agents::vpnaas::ovn' do
    context 'with defaults' do
      it { should contain_class('neutron::params') }

      it 'configures ovn_vpn_agent.ini' do
        should contain_neutron_ovn_vpn_agent_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('vpnagent/vpn_device_driver').with_value(
          'neutron_vpnaas.services.vpn.device_drivers.ovn_ipsec.OvnOpenSwanDriver')
        should contain_neutron_ovn_vpn_agent_config('ipsec/ipsec_status_check_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('DEFAULT/interface_driver').with_value(
          'neutron.agent.linux.interface.OVSInterfaceDriver')
        should contain_neutron_ovn_vpn_agent_config('ovs/ovsdb_connection').with_value('tcp:127.0.0.1:6640')
        should contain_neutron_ovn_vpn_agent_config('ovs/ovsdb_connection_timeout').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('ovn/ovsdb_connection_timeout').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('ovn/ovn_sb_connection').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('ovn/ovn_sb_private_key').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('ovn/ovn_sb_certificate').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('ovn/ovn_sb_ca_cert').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('ovn/ovsdb_retry_max_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_ovn_vpn_agent_config('ovn/ovsdb_probe_interval').with_value('<SERVICE DEFAULT>')
      end

      it 'installs neutron vpnaas ovn vpn agent package' do
        should contain_package('neutron-vpnaas-ovn-vpn-agent').with(
          :ensure => 'installed',
          :name   => platform_params[:vpnaas_ovn_vpn_agent_package],
          :tag    => ['openstack', 'neutron-package'],
        )
      end

      it 'enables neutron vpnaas ovn vpn agent service' do
        should contain_package('neutron-vpnaas-ovn-vpn-agent').with(
          :ensure => 'running',
          :name   => platform_params[:vpnaas_ovn_vpn_service_package],
          :enable => true,
          :tag    => ['neutron-service'],
        )
      end
    end

    context 'with libreswan vpnaas driver' do
      let :params do
        {
          :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.ovn_ipsec.OvnLibreSwanDriver'
        }
      end

      it 'configures ovn_vpn_agent.ini' do
        should contain_neutron_ovn_vpn_agent_config('vpnagent/vpn_device_driver').with_value(
          'neutron_vpnaas.services.vpn.device_drivers.ovn_ipsec.OvnLibreSwanDriver')
      end

      it 'installs libreswan packages' do
        should contain_package('libreswan').with(
          :ensure => 'installed',
          :name   => platform_params[:libreswan_package],
          :tag    => ['openstack', 'neutron-support-package'],
        )
      end
    end

    context 'with strongswan vpnaas driver' do
      let :params do
        {
          :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.ovn_ipsec.OvnStrongSwanDriver'
        }
      end

      it 'configures ovn_vpn_agent.ini' do
        should contain_neutron_ovn_vpn_agent_config('vpnagent/vpn_device_driver').with_value(
          'neutron_vpnaas.services.vpn.device_drivers.ovn_ipsec.OvnStrongSwanDriver')
      end

      it 'installs strongswan packages' do
        should contain_package('strongswan').with(
          :ensure => 'installed',
          :name   => platform_params[:strongswan_package],
          :tag    => ['openstack', 'neutron-support-package'],
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
        case facts[:os]['family']
        when 'Debian'
          {
            :libreswan_package  => 'libreswan',
            :strongswan_package => 'strongswan',
          }
        when 'RedHat'
          {
            :libreswan_package            => 'libreswan',
            :strongswan_package           => 'strongswan',
            :vpnaas_ovn_vpn_agent_package => 'openstack-neutron-vpnaas-ovn-vpn-agent',
            :vpnaas_ovn_vpn_agent_service => 'neutron-vpnaas-ovn-vpn-agent',
          }
        end
      end

      if facts[:os][:family] == 'RedHat'
        it_behaves_like 'neutron::agents::vpnaas::ovn'
      end
    end
  end
end
