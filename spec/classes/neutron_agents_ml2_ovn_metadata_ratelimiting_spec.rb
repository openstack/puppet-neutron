require 'spec_helper'

describe 'neutron::agents::ml2::ovn::metadata_rate_limiting' do
  shared_examples 'neutron::agents::ml2::ovn::metadata_rate_limiting' do
    context 'with defaults' do
      it 'configures the default values' do
        should contain_neutron_agent_ovn('metadata_rate_limiting/rate_limit_enabled').with_value('<SERVICE DEFAULT>');
        should contain_neutron_agent_ovn('metadata_rate_limiting/ip_versions').with_value('<SERVICE DEFAULT>');
        should contain_neutron_agent_ovn('metadata_rate_limiting/base_window_duration').with_value('<SERVICE DEFAULT>');
        should contain_neutron_agent_ovn('metadata_rate_limiting/base_query_rate_limit').with_value('<SERVICE DEFAULT>');
        should contain_neutron_agent_ovn('metadata_rate_limiting/burst_window_duration').with_value('<SERVICE DEFAULT>');
        should contain_neutron_agent_ovn('metadata_rate_limiting/burst_query_rate_limit').with_value('<SERVICE DEFAULT>');
      end
    end

    context 'with parameters' do
      let :params do
        {
          :rate_limit_enabled     => false,
          :ip_versions            => [4],
          :base_window_duration   => 10,
          :base_query_rate_limit  => 11,
          :burst_window_duration  => 12,
          :burst_query_rate_limit => 13,
        }
      end
      it 'configures the given values' do
        should contain_neutron_agent_ovn('metadata_rate_limiting/rate_limit_enabled').with_value(false);
        should contain_neutron_agent_ovn('metadata_rate_limiting/ip_versions').with_value(4);
        should contain_neutron_agent_ovn('metadata_rate_limiting/base_window_duration').with_value(10);
        should contain_neutron_agent_ovn('metadata_rate_limiting/base_query_rate_limit').with_value(11);
        should contain_neutron_agent_ovn('metadata_rate_limiting/burst_window_duration').with_value(12);
        should contain_neutron_agent_ovn('metadata_rate_limiting/burst_query_rate_limit').with_value(13);
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

      it_behaves_like 'neutron::agents::ml2::ovn::metadata_rate_limiting'
    end
  end
end
