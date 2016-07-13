require 'spec_helper'

describe 'neutron::agents::ml2::ovs' do
  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
    { :package_ensure             => 'present',
      :enabled                    => true,
      :bridge_uplinks             => [],
      :bridge_mappings            => [],
      :integration_bridge         => 'br-int',
      :local_ip                   => false,
      :tunnel_types               => [],
      :tunnel_bridge              => 'br-tun',
      :drop_flows_on_start        => false,
      :firewall_driver            => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
      :manage_vswitch             => true,
      :purge_config               => false,
      :enable_dpdk                => false,
      }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  let :params do
    {}
  end

  shared_examples_for 'neutron plugin ovs agent with ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_agent_ovs').with({
        :purge => false
      })
    end

    it 'configures plugins/ml2/openvswitch_agent.ini' do
      is_expected.to contain_neutron_agent_ovs('agent/polling_interval').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_agent_ovs('agent/l2_population').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_agent_ovs('agent/arp_responder').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_agent_ovs('agent/prevent_arp_spoofing').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_agent_ovs('agent/drop_flows_on_start').with_value(p[:drop_flows_on_start])
      is_expected.to contain_neutron_agent_ovs('agent/extensions').with_value(['<SERVICE DEFAULT>'])
      is_expected.to contain_neutron_agent_ovs('ovs/datapath_type').with_value(['<SERVICE DEFAULT>'])
      is_expected.to contain_neutron_agent_ovs('ovs/vhostuser_socket_dir').with_value(['<SERVICE DEFAULT>'])
      is_expected.to contain_neutron_agent_ovs('ovs/ovsdb_interface').with_value(['<SERVICE DEFAULT>'])
      is_expected.to contain_neutron_agent_ovs('ovs/of_interface').with_value(['<SERVICE DEFAULT>'])
      is_expected.to contain_neutron_agent_ovs('ovs/integration_bridge').with_value(p[:integration_bridge])
      is_expected.to contain_neutron_agent_ovs('securitygroup/firewall_driver').\
        with_value(p[:firewall_driver])
      is_expected.to contain_neutron_agent_ovs('ovs/tunnel_bridge').with_ensure('absent')
      is_expected.to contain_neutron_agent_ovs('ovs/local_ip').with_ensure('absent')
      is_expected.to contain_neutron_agent_ovs('ovs/int_peer_patch_port').with_ensure('absent')
      is_expected.to contain_neutron_agent_ovs('ovs/tun_peer_patch_port').with_ensure('absent')
    end

    it 'installs neutron ovs agent package' do
      if platform_params.has_key?(:ovs_agent_package)
        is_expected.to contain_package('neutron-ovs-agent').with(
          :name   => platform_params[:ovs_agent_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
      else
      end
    end

    it 'configures neutron ovs agent service' do
      is_expected.to contain_service('neutron-ovs-agent-service').with(
        :name    => platform_params[:ovs_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => ['neutron-service', 'neutron-db-sync-service'],
      )
      is_expected.to contain_service('neutron-ovs-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('neutron-ovs-agent-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        is_expected.to contain_service('neutron-ovs-agent-service').without_ensure
      end
    end

    context 'when supplying a firewall driver' do
      before :each do
        params.merge!(:firewall_driver => false)
      end
      it 'should configure firewall driver' do
        is_expected.to contain_neutron_agent_ovs('securitygroup/firewall_driver').with_ensure('absent')
      end
    end

    context 'when enabling ARP responder' do
      before :each do
        params.merge!(:arp_responder => true)
      end
      it 'should enable ARP responder' do
        is_expected.to contain_neutron_agent_ovs('agent/arp_responder').with_value(true)
      end
    end

    context 'when disabling ARP Spoofing Protection' do
      before :each do
        params.merge!(:prevent_arp_spoofing => false)
      end
      it 'should disable ARP Spoofing Protection' do
        is_expected.to contain_neutron_agent_ovs('agent/prevent_arp_spoofing').with_value(false)
      end
    end

    context 'when enabling DVR' do
      before :each do
        params.merge!(:enable_distributed_routing => true,
                      :l2_population              => true )
      end
      it 'should enable DVR' do
        is_expected.to contain_neutron_agent_ovs('agent/enable_distributed_routing').with_value(true)
      end
    end

    context 'when supplying bridge mappings for provider networks' do
      before :each do
        params.merge!(:bridge_uplinks => ['br-ex:eth2'],:bridge_mappings => ['default:br-ex'])
      end

      it 'should require vswitch::ovs' do
        is_expected.to contain_class('vswitch::ovs')
      end

      it 'configures bridge mappings' do
        is_expected.to contain_neutron_agent_ovs('ovs/bridge_mappings')
      end

      it 'should configure bridge mappings' do
        is_expected.to contain_neutron__plugins__ovs__bridge(params[:bridge_mappings].join(',')).with(
          :before => 'Service[neutron-ovs-agent-service]'
        )
      end

      it 'should configure bridge uplinks' do
        is_expected.to contain_neutron__plugins__ovs__port(params[:bridge_uplinks].join(',')).with(
          :before => 'Service[neutron-ovs-agent-service]'
        )
      end
    end

    context 'when supplying bridge mappings for provider networks with manage vswitch set to false' do
      before :each do
        params.merge!(:bridge_uplinks => ['br-ex:eth2'],:bridge_mappings => ['default:br-ex'], :manage_vswitch => false)
      end

      it 'should not require vswitch::ovs' do
        is_expected.not_to contain_class('vswitch::ovs')
      end

      it 'configures bridge mappings' do
        is_expected.to contain_neutron_agent_ovs('ovs/bridge_mappings')
      end

      it 'should not configure bridge mappings' do
        is_expected.not_to contain_neutron__plugins__ovs__bridge(params[:bridge_mappings].join(',')).with(
          :before => 'Service[neutron-ovs-agent-service]'
        )
      end

      it 'should not configure bridge uplinks' do
        is_expected.not_to contain_neutron__plugins__ovs__port(params[:bridge_uplinks].join(',')).with(
          :before => 'Service[neutron-ovs-agent-service]'
        )
      end
    end

    context 'when supplying extensions for ML2 plugin' do
      before :each do
        params.merge!(:extensions => ['qos'])
      end

      it 'configures extensions' do
        is_expected.to contain_neutron_agent_ovs('agent/extensions').with_value(params[:extensions].join(','))
      end
    end

    context 'when supplying DPDK specific options' do
      before :each do
        params.merge!(:datapath_type => 'netdev', :vhostuser_socket_dir => '/var/run/openvswitch')
      end

      it 'configures ovs for DPDK' do
        is_expected.to contain_neutron_agent_ovs('ovs/datapath_type').with_value(params[:datapath_type])
        is_expected.to contain_neutron_agent_ovs('ovs/vhostuser_socket_dir').with_value(params[:vhostuser_socket_dir])
      end
    end

    context 'when enabling tunneling' do
      context 'without local ip address' do
        before :each do
          params.merge!(:tunnel_types => ['vxlan'])
        end

        it_raises 'a Puppet::Error', /Local ip for ovs agent must be set when tunneling is enabled/
      end
      context 'with default params' do
        before :each do
          params.merge!(:tunnel_types => ['vxlan'], :local_ip => '127.0.0.1' )
        end
        it 'should configure ovs for tunneling' do
          is_expected.to contain_neutron_agent_ovs('ovs/tunnel_bridge').with_value(default_params[:tunnel_bridge])
          is_expected.to contain_neutron_agent_ovs('ovs/local_ip').with_value('127.0.0.1')
          is_expected.to contain_neutron_agent_ovs('ovs/int_peer_patch_port').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_neutron_agent_ovs('ovs/tun_peer_patch_port').with_value('<SERVICE DEFAULT>')
        end
      end

      context 'with vxlan tunneling' do
        before :each do
          params.merge!(:local_ip => '127.0.0.1',
                        :tunnel_types => ['vxlan'],
                        :vxlan_udp_port => '4789')
        end

        it 'should perform vxlan network configuration' do
          is_expected.to contain_neutron_agent_ovs('agent/tunnel_types').with_value(params[:tunnel_types])
          is_expected.to contain_neutron_agent_ovs('agent/vxlan_udp_port').with_value(params[:vxlan_udp_port])
        end
      end

      context 'when l2 population is disabled and DVR and tunneling enabled' do
        before :each do
          params.merge!(:enable_distributed_routing => true,
                        :l2_population              => false,
                        :tunnel_types               => ['vxlan'],
                        :local_ip                   => '127.0.0.1' )
        end

        it_raises 'a Puppet::Error', /L2 population must be enabled when DVR and tunneling are enabled/
      end

      context 'when DVR is enabled and l2 population and tunneling are disabled' do
        before :each do
          params.merge!(:enable_distributed_routing => true,
                        :l2_population              => false,
                        :tunnel_types               => [] )
        end

        it 'should enable DVR without L2 population' do
          is_expected.to contain_neutron_agent_ovs('agent/enable_distributed_routing').with_value(true)
          is_expected.to contain_neutron_agent_ovs('agent/l2_population').with_value(false)
        end
      end
    end

    context 'when supplying ovsdb_interface' do
      context 'with incorrect value' do
        before :each do
          params.merge!(:ovsdb_interface => 'random')
        end
        it_raises 'a Puppet::Error', /A value of \$ovsdb_interface is incorrect. The allowed values are vsctl and native/
      end

      context 'with supported value' do
        before :each do
          params.merge!(:ovsdb_interface => 'native')
        end
        it 'should configure ovsdb_interface for ovs' do
          is_expected.to contain_neutron_agent_ovs('ovs/ovsdb_interface').with_value('native')
        end
      end
    end

    context 'when supplying of_interface' do
      context 'with incorrect value' do
        before :each do
          params.merge!(:of_interface => 'random')
        end
        it_raises 'a Puppet::Error', /A value of \$of_interface is incorrect. The allowed values are ovs-ofctl and native/
      end

      context 'with supported value' do
        before :each do
          params.merge!(:of_interface => 'native')
        end
        it 'should configure of_interface for ovs' do
          is_expected.to contain_neutron_agent_ovs('ovs/of_interface').with_value('native')
        end
      end
    end

    context 'when enabling dpdk with manage vswitch disabled' do
      before :each do
        params.merge!(:enable_dpdk => true, :manage_vswitch => false)
      end

      it_raises 'a Puppet::Error',/Enabling DPDK without manage vswitch does not have any effect/
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian',
         :os_package_type => 'debian'
      }))
    end

    let :platform_params do
      { :ovs_agent_package => 'neutron-openvswitch-agent',
        :ovs_agent_service => 'neutron-openvswitch-agent' }
    end

    it_configures 'neutron plugin ovs agent with ml2 plugin'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :platform_params do
      { :ovs_cleanup_service => 'neutron-ovs-cleanup',
        :ovs_agent_service   => 'neutron-openvswitch-agent' }
    end

    it_configures 'neutron plugin ovs agent with ml2 plugin'

    it 'configures neutron ovs cleanup service' do
      is_expected.to contain_service('ovs-cleanup-service').with(
        :name    => platform_params[:ovs_cleanup_service],
        :enable  => true
      ).that_requires('Package[neutron]')
      is_expected.to contain_package('neutron-ovs-agent').that_requires('Anchor[neutron::install::begin]')
      is_expected.to contain_package('neutron-ovs-agent').that_notifies('Anchor[neutron::install::end]')
    end

    context 'when enabling dpdk with manage vswitch is default' do
      let :pre_condition do
        "class { 'vswitch::dpdk': core_list => '1,2', memory_channels => '1' }"
      end
      before :each do
        params.merge!(:enable_dpdk => true,
                      :datapath_type => 'netdev',
                      :vhostuser_socket_dir => '/var/run/openvswitch')
      end

      it 'should require vswitch::dpdk' do
        is_expected.to contain_class('vswitch::dpdk')
      end
    end
  end
end
