require 'spec_helper'

describe 'neutron::config' do
  let(:config_hash) do {
    'DEFAULT/foo' => { 'value'  => 'fooValue' },
    'DEFAULT/bar' => { 'value'  => 'barValue' },
    'DEFAULT/baz' => { 'ensure' => 'absent' }
  }
  end

  shared_examples 'neutron_config' do
    let :params do
      { :server_config => config_hash }
    end

    it { should contain_class('neutron::deps') }

    it 'configures arbitrary neutron-config configurations' do
      should contain_neutron_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_config('DEFAULT/baz').with_ensure('absent')
    end
  end

  shared_examples 'neutron_api_paste_ini' do
    let :params do
      { :api_paste_ini => config_hash }
    end

    it 'configures arbitrary neutron-api-paste configurations' do
      should contain_neutron_api_paste_ini('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_api_paste_ini('DEFAULT/bar').with_value('barValue')
      should contain_neutron_api_paste_ini('DEFAULT/baz').with_ensure('absent')
    end
  end


  shared_examples 'neutron_rootwrap_config' do
    let :params do
      { :rootwrap_config => config_hash }
    end

    it { should contain_class('neutron::deps') }

    it 'configures arbitrary rootwrap configurations' do
      should contain_neutron_rootwrap_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_rootwrap_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_rootwrap_config('DEFAULT/baz').with_ensure('absent')
    end
  end

  shared_examples 'neutron_service_config' do
    let :params do
      { :sfc_service_config  => config_hash,
        :l2gw_service_config => config_hash,
      }
    end

    it 'configures arbitrary sfc_service_config configurations' do
      should contain_neutron_sfc_service_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_sfc_service_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_sfc_service_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary l2gw_service_config configurations' do
      should contain_neutron_l2gw_service_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_l2gw_service_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_l2gw_service_config('DEFAULT/baz').with_ensure('absent')
    end
  end

  shared_examples 'neutron_agent_config' do
    let :params do
      { :ovs_agent_config         => config_hash,
        :ovn_agent_config         => config_hash,
        :sriov_agent_config       => config_hash,
        :macvtap_agent_config     => config_hash,
        :l3_agent_config          => config_hash,
        :dhcp_agent_config        => config_hash,
        :metadata_agent_config    => config_hash,
        :metering_agent_config    => config_hash,
        :fwaas_agent_config       => config_hash,
        :fwaas_service_config     => config_hash,
        :vpnaas_agent_config      => config_hash,
        :vpnaas_service_config    => config_hash,
        :ovn_vpn_agent_config     => config_hash,
        :taas_service_config      => config_hash,
        :l2gw_agent_config        => config_hash,
        :bgp_dragent_config       => config_hash,
      }
    end

    it 'configures arbitrary neutron_agent_ovs configurations' do
      should contain_neutron_agent_ovs('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_agent_ovs('DEFAULT/bar').with_value('barValue')
      should contain_neutron_agent_ovs('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_agent_ovn configurations' do
      should contain_neutron_agent_ovn('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_agent_ovn('DEFAULT/bar').with_value('barValue')
      should contain_neutron_agent_ovn('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_sriov_agent_config configurations' do
      should contain_neutron_sriov_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_sriov_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_sriov_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_agent_macvtap configurations' do
      should contain_neutron_agent_macvtap('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_agent_macvtap('DEFAULT/bar').with_value('barValue')
      should contain_neutron_agent_macvtap('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary l3_agent_config configurations' do
      should contain_neutron_l3_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_l3_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_l3_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary dhcp_agent_config configurations' do
      should contain_neutron_dhcp_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_dhcp_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_dhcp_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary metadata_agent_config configurations' do
      should contain_neutron_metadata_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_metadata_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_metadata_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary metering_agent_config configurations' do
      should contain_neutron_metering_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_metering_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_metering_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary fwaas_agent_config configurations' do
      should contain_neutron_fwaas_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_fwaas_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_fwaas_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary fwaas_service_config configurations' do
      should contain_neutron_fwaas_service_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_fwaas_service_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_fwaas_service_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary vpnaas_agent_config configurations' do
      should contain_neutron_vpnaas_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_vpnaas_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_vpnaas_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary vpnaas_service_config configurations' do
      should contain_neutron_vpnaas_service_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_vpnaas_service_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_vpnaas_service_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary ovn_vpn_agent_config configurations' do
      should contain_neutron_ovn_vpn_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_ovn_vpn_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_ovn_vpn_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary taas_service_config configurations' do
      should contain_neutron_taas_service_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_taas_service_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_taas_service_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary l2gw_agent_config configurations' do
      should contain_neutron_l2gw_agent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_l2gw_agent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_l2gw_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary bgp_dragent_config configurations' do
      should contain_neutron_bgp_dragent_config('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_bgp_dragent_config('DEFAULT/bar').with_value('barValue')
      should contain_neutron_bgp_dragent_config('DEFAULT/baz').with_ensure('absent')
    end

  end

  shared_examples 'neutron_plugin_config' do
    let :params do
      {
        :plugin_ml2_config => config_hash
      }
    end

    it 'configures arbitrary neutron_plugin_ml2 configurations' do
      should contain_neutron_plugin_ml2('DEFAULT/foo').with_value('fooValue')
      should contain_neutron_plugin_ml2('DEFAULT/bar').with_value('barValue')
      should contain_neutron_plugin_ml2('DEFAULT/baz').with_ensure('absent')
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron_config'
      it_behaves_like 'neutron_api_paste_ini'
      it_behaves_like 'neutron_rootwrap_config'
      it_behaves_like 'neutron_service_config'
      it_behaves_like 'neutron_agent_config'
      it_behaves_like 'neutron_plugin_config'
    end
  end
end
