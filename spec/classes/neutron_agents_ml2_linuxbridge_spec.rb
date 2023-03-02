require 'spec_helper'

describe 'neutron::agents::ml2::linuxbridge' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :default_params do
    {
      :package_ensure              => 'present',
      :enabled                     => true,
      :tunnel_types                => [],
      :local_ip                    => false,
      :physical_interface_mappings => [],
      :bridge_mappings             => [],
      :firewall_driver             => 'iptables',
      :purge_config                => false,}
  end

  let :params do
    {}
  end

  shared_examples 'neutron plugin linuxbridge agent with ml2 plugin' do
    context 'with default parameters' do
      it { should contain_class('neutron::params') }

      it 'passes purge to resource' do
        should contain_resources('neutron_agent_linuxbridge').with({
          :purge => false
        })
      end

      it 'configures ml2_conf.ini' do
        should contain_neutron_agent_linuxbridge('DEFAULT/rpc_response_max_timeout').with_value('<SERVICE DEFAULT>')
        should contain_neutron_agent_linuxbridge('agent/polling_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_agent_linuxbridge('linux_bridge/physical_interface_mappings').with_value(default_params[:physical_interface_mappings].join(','))
        should contain_neutron_agent_linuxbridge('linux_bridge/bridge_mappings').with_ensure('absent')
        should contain_neutron_agent_linuxbridge('securitygroup/firewall_driver').with_value(default_params[:firewall_driver])
        should contain_neutron_agent_linuxbridge('agent/tunnel_types').with_ensure('absent')
      end

      it 'installs neutron linuxbridge agent package' do
        should contain_package('neutron-plugin-linuxbridge-agent').with(
          :name   => platform_params[:linuxbridge_agent_package],
          :ensure => default_params[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
      end

      it 'configures neutron linuxbridge agent service' do
        should contain_service('neutron-plugin-linuxbridge-agent').with(
          :name    => platform_params[:linuxbridge_agent_service],
          :enable  => true,
          :ensure  => 'running',
          :tag     => 'neutron-service',
        )
        should contain_service('neutron-plugin-linuxbridge-agent').that_subscribes_to('Anchor[neutron::service::begin]')
        should contain_service('neutron-plugin-linuxbridge-agent').that_notifies('Anchor[neutron::service::end]')
      end

      context 'with manage_service as false' do
        before :each do
          params.merge!(:manage_service => false)
        end
        it 'should not manage the service' do
          should_not contain_service('neutron-plugin-linuxbridge-agent')
        end
      end

      it 'does not configure VXLAN tunneling' do
        should contain_neutron_agent_linuxbridge('vxlan/enable_vxlan').with_value(false)
        should contain_neutron_agent_linuxbridge('vxlan/local_ip').with_ensure('absent')
        should_not contain_neutron_agent_linuxbridge('vxlan/vxlan_group')
        should_not contain_neutron_agent_linuxbridge('vxlan/l2_population')
      end
    end

    context 'with VXLAN tunneling enabled' do
      before do
        params.merge!({
          :tunnel_types  => ['vxlan'],
          :local_ip      => '192.168.0.10'
        })
      end

      context 'when providing all parameters' do
        it 'configures ml2_conf.ini' do
          should contain_neutron_agent_linuxbridge('vxlan/local_ip').with_value(params[:local_ip])
          should contain_neutron_agent_linuxbridge('vxlan/vxlan_group').with_value('<SERVICE DEFAULT>')
          should contain_neutron_agent_linuxbridge('vxlan/ttl').with_value('<SERVICE DEFAULT>')
          should contain_neutron_agent_linuxbridge('vxlan/tos').with_value('<SERVICE DEFAULT>')
          should contain_neutron_agent_linuxbridge('vxlan/l2_population').with_value('<SERVICE DEFAULT>')
          should contain_neutron_agent_linuxbridge('agent/tunnel_types').with_value(params[:tunnel_types])
        end
      end

      context 'when not providing or overriding some parameters' do
        before do
          params.merge!({
            :vxlan_group   => '224.0.0.2',
            :vxlan_ttl     => 10,
            :vxlan_tos     => 2,
            :l2_population => true,
          })
        end

        it 'configures ml2_conf.ini' do
          should contain_neutron_agent_linuxbridge('vxlan/local_ip').with_value(params[:local_ip])
          should contain_neutron_agent_linuxbridge('vxlan/vxlan_group').with_value(params[:vxlan_group])
          should contain_neutron_agent_linuxbridge('vxlan/ttl').with_value(params[:vxlan_ttl])
          should contain_neutron_agent_linuxbridge('vxlan/tos').with_value(params[:vxlan_tos])
          should contain_neutron_agent_linuxbridge('vxlan/l2_population').with_value(params[:l2_population])
        end
      end
    end

    context 'when providing the physical_interface_mappings parameter' do
      before do
        params.merge!(:physical_interface_mappings => ['physnet0:eth0', 'physnet1:eth1'])
      end

      it 'configures physical interface mappings' do
        should contain_neutron_agent_linuxbridge('linux_bridge/physical_interface_mappings').with_value(
          params[:physical_interface_mappings].join(',')
        )
      end
    end

    context 'when providing the bridge_mappings parameter' do
      before do
        params.merge!(:bridge_mappings => ['physnet0:br0', 'physnet1:br1'])
      end

      it 'configures bridge mappings' do
        should contain_neutron_agent_linuxbridge('linux_bridge/bridge_mappings').with_value(
          params[:bridge_mappings].join(',')
        )
      end
    end

    context 'with firewall_driver parameter set to false' do
      before :each do
        params.merge!(:firewall_driver => false)
      end
      it 'removes firewall driver configuration' do
        should contain_neutron_agent_linuxbridge('securitygroup/firewall_driver').with_ensure('absent')
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
            :linuxbridge_agent_package => 'neutron-linuxbridge-agent',
            :linuxbridge_agent_service => 'neutron-linuxbridge-agent'
          }
        when 'RedHat'
          {
            :linuxbridge_agent_package => 'openstack-neutron-linuxbridge',
            :linuxbridge_agent_service => 'neutron-linuxbridge-agent'
          }
        end
      end

      it_behaves_like 'neutron plugin linuxbridge agent with ml2 plugin'
    end
  end
end
