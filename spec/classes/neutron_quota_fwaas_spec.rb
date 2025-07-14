require 'spec_helper'

describe 'neutron::quota::fwaas' do
  let :params do
    {}
  end

  let :default_params do
    {
      :quota_firewall_group  => '<SERVICE DEFAULT>',
      :quota_firewall_policy => '<SERVICE DEFAULT>',
      :quota_firewall_rule   => '<SERVICE DEFAULT>',
    }
  end

  shared_examples 'neutron::quota::fwaas test' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures quota in neutron.conf' do
      params_hash.each_pair do |config,value|
        should contain_neutron_config("quotas/#{config}").with_value( value )
      end
    end
  end

  shared_examples 'neutron::quota::fwaas' do
    context 'with default' do
      it_behaves_like 'neutron::quota::fwaas test'
    end

    context 'with provided parameters' do
      before do
        params.merge!({
          :quota_firewall_group  => 10,
          :quota_firewall_policy => 11,
          :quota_firewall_rule   => 100,
        })
      end

      it_behaves_like 'neutron::quota::fwaas test'
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::quota::fwaas'
    end
  end
end
