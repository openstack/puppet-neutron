require 'spec_helper'

describe 'neutron::config' do

  let(:config_hash) do {
    'DEFAULT/foo' => { 'value'  => 'fooValue' },
    'DEFAULT/bar' => { 'value'  => 'barValue' },
    'DEFAULT/baz' => { 'ensure' => 'absent' }
  }
  end

  shared_examples_for 'neutron_config' do
    let :params do
      { :server_config => config_hash }
    end

    it 'configures arbitrary neutron-config configurations' do
      is_expected.to contain_neutron_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_config('DEFAULT/baz').with_ensure('absent')
    end
  end

  shared_examples_for 'neutron_api_config' do
    let :params do
      { :api_config => config_hash }
    end

    it 'configures arbitrary neutron-api-config configurations' do
      is_expected.to contain_neutron_api_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_api_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_api_config('DEFAULT/baz').with_ensure('absent')
    end
  end

  shared_examples_for 'neutron_agent_config' do
    let :params do
      { :l3_agent_config        => config_hash,
        :dhcp_agent_config      => config_hash,
        :metadata_agent_config  => config_hash,
        :metering_agent_config  => config_hash,
        :vpnaas_agent_config    => config_hash,
      }
    end

    it 'configures arbitrary l3_agent_config configurations' do
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary dhcp_agent_config configurations' do
      is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary metadata_agent_config configurations' do
      is_expected.to contain_neutron_metadata_agent_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_metadata_agent_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_metadata_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary metering_agent_config configurations' do
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_metering_agent_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary vpnaas_agent_config configurations' do
      is_expected.to contain_neutron_vpnaas_agent_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_vpnaas_agent_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_vpnaas_agent_config('DEFAULT/baz').with_ensure('absent')
    end

  end

  shared_examples_for 'neutron_plugin_config' do
    let :params do
      {
        :plugin_linuxbridge_config     => config_hash,
        :plugin_cisco_db_conn_config   => config_hash,
        :plugin_cisco_l2network_config => config_hash,
        :plugin_cisco_config           => config_hash,
        :plugin_midonet_config         => config_hash,
        :plugin_plumgrid_config        => config_hash,
        :plugin_opencontrail_config    => config_hash,
        :plugin_nuage_config           => config_hash,
        :plugin_ml2_config             => config_hash
      }
    end

    it 'configures arbitrary neutron_plugin_linuxbridge configurations' do
      is_expected.to contain_neutron_plugin_linuxbridge('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_linuxbridge('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_linuxbridge('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_cisco_db_conn configurations' do
      is_expected.to contain_neutron_plugin_cisco_db_conn('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_cisco_db_conn('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_cisco_db_conn('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_cisco_l2network configurations' do
      is_expected.to contain_neutron_plugin_cisco_l2network('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_cisco_l2network('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_cisco_l2network('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_cisco configurations' do
      is_expected.to contain_neutron_plugin_cisco('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_cisco('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_cisco('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_midonet configurations' do
      is_expected.to contain_neutron_plugin_midonet('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_midonet('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_midonet('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_plumgrid configurations' do
      is_expected.to contain_neutron_plugin_plumgrid('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_plumgrid('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_plumgrid('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_opencontrail configurations' do
      is_expected.to contain_neutron_plugin_opencontrail('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_opencontrail('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_opencontrail('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_nuage configurations' do
      is_expected.to contain_neutron_plugin_nuage('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_nuage('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_nuage('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary neutron_plugin_ml2 configurations' do
      is_expected.to contain_neutron_plugin_ml2('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_neutron_plugin_ml2('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_neutron_plugin_ml2('DEFAULT/baz').with_ensure('absent')
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'neutron_config'
      it_configures 'neutron_api_config'
      it_configures 'neutron_agent_config'
      it_configures 'neutron_plugin_config'
    end
  end
end
