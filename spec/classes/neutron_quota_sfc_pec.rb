require 'spec_helper'

describe 'neutron::quota::sfc' do
  let :params do
    {}
  end

  let :default_params do
    {
      :quota_port_chain      => '<SERVICE DEFAULT>',
      :quota_port_pair_group => '<SERVICE DEFAULT>',
      :quota_port_pair       => '<SERVICE DEFAULT>',
      :quota_service_graphs  => '<SERVICE DEFAULT>',
      :quota_flow_classifier => '<SERVICE DEFAULT>',
    }
  end

  shared_examples 'neutron::quota::sfc test' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures quota in neutron.conf' do
      params_hash.each_pair do |config,value|
        should contain_neutron_config("quotas/#{config}").with_value( value )
      end
    end
  end

  shared_examples 'neutron::quota::sfc' do
    context 'with default' do
      it_behaves_like 'neutron::quota::sfc test'
    end

    context 'with provided parameters' do
      before do
        params.merge!({
          :quota_port_chain      => 10,
          :quota_port_pair_group => 11,
          :quota_port_pair       => 100,
          :quota_service_graphs  => 12,
          :quota_flow_classifier => 101,
        })
      end

      it_behaves_like 'neutron::quota::sfc test'
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::quota::sfc'
    end
  end
end
