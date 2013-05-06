require 'spec_helper'

describe 'quantum::agents::l3' do

  let :params do
    {
      :external_network_bridge => 'br-floating'
    }
  end

  shared_examples_for 'quantum l3 agent' do
    it { should include_class('quantum::params') }

    it 'configures quantum l3 agent' do
      should contain_quantum_l3_agent_config('DEFAULT/external_network_bridge').with(
        :value => params[:external_network_bridge]
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'quantum l3 agent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'quantum l3 agent'
  end
end
