require 'spec_helper'

describe 'neutron::rootwrap' do
  let :params do
    {}
  end

  shared_examples 'neutron rootwrap' do
    it 'configures rootwrap.conf' do
      # Now this class doesn't have any effective parameters
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|

    context "on #{os}" do
      let(:facts) do
        facts.merge!(OSDefaults.get_facts({
        }))
      end

      it_behaves_like 'neutron rootwrap'
    end
  end
end
