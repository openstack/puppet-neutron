require 'spec_helper'

describe 'neutron::quota' do
  let :params do
    {}
  end

  let :default_params do
    {
      :quota_network             => '<SERVICE DEFAULT>',
      :quota_subnet              => '<SERVICE DEFAULT>',
      :quota_port                => '<SERVICE DEFAULT>',
      :quota_router              => '<SERVICE DEFAULT>',
      :quota_floatingip          => '<SERVICE DEFAULT>',
      :quota_security_group      => '<SERVICE DEFAULT>',
      :quota_security_group_rule => '<SERVICE DEFAULT>',
      :quota_rbac_policy         => '<SERVICE DEFAULT>',
    }
  end

  shared_examples 'neutron::quota test' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures quota in neutron.conf' do
      params_hash.each_pair do |config,value|
        should contain_neutron_config("quotas/#{config}").with_value( value )
      end
    end
  end

  shared_examples 'neutron::quota' do
    context 'with default' do
      it_behaves_like 'neutron::quota test'
    end

    context 'with provided parameters' do
      before do
        params.merge!({
          :quota_network             => 20,
          :quota_subnet              => 20,
          :quota_port                => 100,
          :quota_router              => 20,
          :quota_floatingip          => 100,
          :quota_security_group      => 20,
          :quota_security_group_rule => 200,
          :quota_rbac_policy         => 10
        })
      end

      it_behaves_like 'neutron::quota test'
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::quota'
    end
  end
end
