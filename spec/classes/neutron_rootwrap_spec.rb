require 'spec_helper'

describe 'neutron::rootwrap' do
  let :pre_condition do
    "class { 'neutron::agents::ml2::ovs': }"
  end

  let :params do
    { :xenapi_connection_url      => 'http://127.0.0.1',
      :xenapi_connection_username => 'user',
      :xenapi_connection_password => 'passw0rd',
    }
  end

  shared_examples 'neutron rootwrap' do

    it 'configures rootwrap.conf' do
      should contain_neutron_rootwrap_config('xenapi/xenapi_connection_url').with_value(params[:xenapi_connection_url]);
      should contain_neutron_rootwrap_config('xenapi/xenapi_connection_username').with_value(params[:xenapi_connection_username]);
      should contain_neutron_rootwrap_config('xenapi/xenapi_connection_password').with_value(params[:xenapi_connection_password]);
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
