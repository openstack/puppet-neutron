require 'spec_helper'

describe 'neutron::agents::ml2::ovn::metadata' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {
      :shared_secret => 'metadata-secret',
    }
  end

  shared_examples 'neutron::agents::ml2::ovn::metadata' do
    it 'configures ovn_agent.ini' do
      should contain_neutron_agent_ovn('DEFAULT/auth_ca_cert').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/nova_client_cert').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/nova_client_priv_key').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/nova_metadata_host').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/nova_metadata_port').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/nova_metadata_protocol').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/metadata_workers').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/metadata_backlog').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/nova_metadata_insecure').with_value('<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/metadata_proxy_shared_secret').with_value(params[:shared_secret]).with_secret(true)
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end
      it_behaves_like 'neutron::agents::ml2::ovn::metadata'
    end
  end
end
