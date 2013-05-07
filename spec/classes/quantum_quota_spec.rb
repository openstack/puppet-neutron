require 'spec_helper'

describe 'quantum::quota' do

  let :params do
    {}
  end

  let :default_params do
    { :default_quota             => -1,
      :quota_network             => 10,
      :quota_subnet              => 10,
      :quota_port                => 50,
      :quota_router              => 10,
      :quota_floatingip          => 50,
      :quota_security_group      => 10,
      :quota_security_group_rule => 100,
      :quota_driver              => 'quantum.quota.ConfDriver' }
  end

  shared_examples_for 'quantum quota' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures quota in quantum.conf' do
      params_hash.each_pair do |config,value|
        should contain_quantum_config("QUOTAS/#{config}").with_value( value )
      end
    end
  end

  context 'with default parameters' do
    it_configures 'quantum quota'
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
        :quota_security_group_rule => 200
      })
    end

    it_configures 'quantum quota'
  end
end
