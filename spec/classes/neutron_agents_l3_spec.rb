require 'spec_helper'

describe 'neutron::agents::l3' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :default_params do
    {
      :package_ensure   => 'present',
      :interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron l3 agent' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'configures l3_agent.ini' do
      should contain_neutron_l3_agent_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver])
      should contain_neutron_l3_agent_config('DEFAULT/handle_internal_only_routers').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/metadata_port').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/periodic_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/periodic_fuzzy_delay').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/enable_metadata_proxy').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_type').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_password').with_value('<SERVICE DEFAULT>').with_secret(true)
      should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_advert_int').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_keepalived_state_change_server_threads').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_health_check_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_enabled').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_hashsize').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_hashlimit').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_unix_backlog').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_socketbuffersize').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_socketbuffersize_max_grown').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_ipv4_mcast_addr').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_group').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_sndsocketbuffer').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_rcvsocketbuffer').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/agent_mode').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/radvd_user').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('ovs/integration_bridge').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('agent/availability_zone').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('agent/extensions').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('agent/report_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/rpc_response_max_timeout').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('network_log/rate_limit').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('network_log/burst_limit').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('network_log/local_output_log_base').with_value('<SERVICE DEFAULT>')
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_l3_agent_config').with({
        :purge => false
      })
    end

    it 'installs neutron l3 agent package' do
      if platform_params.has_key?(:l3_agent_package)
        should contain_package('neutron-l3').with(
          :name    => platform_params[:l3_agent_package],
          :ensure  => p[:package_ensure],
          :tag     => ['openstack', 'neutron-package'],
        )
        should contain_package('neutron-l3').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron-l3').that_notifies('Anchor[neutron::install::end]')
      else
        should contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    context 'with manage_service as true' do
      before :each do
        params.merge!(:manage_service => true)
      end
      it 'configures neutron l3 agent service' do
        should contain_service('neutron-l3').with(
          :name    => platform_params[:l3_agent_service],
          :enable  => true,
          :ensure  => 'running',
          :tag     => 'neutron-service',
        )
        should contain_service('neutron-l3').that_subscribes_to('Anchor[neutron::service::begin]')
        should contain_service('neutron-l3').that_notifies('Anchor[neutron::service::end]')
      end
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not manage the service' do
        should_not contain_service('neutron-l3')
      end
    end

    context 'with DVR' do
      before :each do
        params.merge!(:agent_mode => 'dvr')
      end
      it 'should enable DVR mode' do
        should contain_neutron_l3_agent_config('DEFAULT/agent_mode').with_value(p[:agent_mode])
      end
    end

    context 'with radvd user' do
      before :each do
        params.merge!(:radvd_user => 'root')
      end

      it 'configures radvd user' do
        should contain_neutron_l3_agent_config('DEFAULT/radvd_user').with_value(p[:radvd_user])
      end
    end

    context 'with HA options' do
      before :each do
        params.merge!({
          :ha_vrrp_auth_type                         => 'PASS',
          :ha_vrrp_auth_password                     => 'secrete',
          :ha_vrrp_advert_int                        => 3,
          :ha_keepalived_state_change_server_threads => 2,
          :ha_vrrp_health_check_interval             => 0,
        })
      end
      it 'should configure VRRP' do
        should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_type').with_value(p[:ha_vrrp_auth_type])
        should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_password').with_value(p[:ha_vrrp_auth_password]).with_secret(true)
        should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_advert_int').with_value(p[:ha_vrrp_advert_int])
        should contain_neutron_l3_agent_config('DEFAULT/ha_keepalived_state_change_server_threads').with_value(
          p[:ha_keepalived_state_change_server_threads])
        should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_health_check_interval').with_value(p[:ha_vrrp_health_check_interval])
      end
    end

    context 'with conntrackd options' do
      before :each do
        params.merge!({
          :ha_conntrackd_enabled                    => false,
          :ha_conntrackd_hashsize                   => 32768,
          :ha_conntrackd_hashlimit                  => 131072,
          :ha_conntrackd_unix_backlog               => 20,
          :ha_conntrackd_socketbuffersize           => 262142,
          :ha_conntrackd_socketbuffersize_max_grown => 655355,
          :ha_conntrackd_ipv4_mcast_addr            => '225.0.0.50',
          :ha_conntrackd_group                      => 3780,
          :ha_conntrackd_sndsocketbuffer            => 24985600,
          :ha_conntrackd_rcvsocketbuffer            => 24985601,
        })
      end
      it 'should configure conntrackd' do
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_enabled').with_value(false)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_hashsize').with_value(32768)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_hashlimit').with_value(131072)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_unix_backlog').with_value(20)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_socketbuffersize').with_value(262142)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_socketbuffersize_max_grown').with_value(655355)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_ipv4_mcast_addr').with_value('225.0.0.50')
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_group').with_value(3780)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_sndsocketbuffer').with_value(24985600)
        should contain_neutron_l3_agent_config('DEFAULT/ha_conntrackd_rcvsocketbuffer').with_value(24985601)
      end
    end

    context 'with ovs_integration_bridge' do
      before :each do
        params.merge!(:ovs_integration_bridge => 'br-int')
      end
      it 'should configure ovs_integration_bridge' do
        should contain_neutron_l3_agent_config('ovs/integration_bridge').with_value(p[:ovs_integration_bridge])
      end
    end

    context 'with availability zone' do
      before :each do
        params.merge!(:availability_zone => 'zone1')
      end

      it 'configures availability zone' do
        should contain_neutron_l3_agent_config('agent/availability_zone').with_value(p[:availability_zone])
      end
    end

    context 'with extensions in string' do
      before :each do
        params.merge!(:extensions => 'fip_qos,gateway_ip_qos,port_forwarding')
      end

      it 'configures extensions' do
        should contain_neutron_l3_agent_config('agent/extensions').with_value('fip_qos,gateway_ip_qos,port_forwarding')
      end
    end

    context 'with extensions in array' do
      before :each do
        params.merge!(:extensions => ['fip_qos', 'gateway_ip_qos', 'port_forwarding'])
      end

      it 'configures extensions' do
        should contain_neutron_l3_agent_config('agent/extensions').with_value('fip_qos,gateway_ip_qos,port_forwarding')
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
            :l3_agent_package => 'neutron-l3-agent',
            :l3_agent_service => 'neutron-l3-agent'
          }
        when 'RedHat'
          {
            :l3_agent_service => 'neutron-l3-agent'
          }
        end
      end

      it_behaves_like 'neutron l3 agent'
    end
  end
end
