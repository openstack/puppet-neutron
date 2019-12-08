require 'spec_helper'

describe 'neutron::plugins::ml2::vpp' do
  let :pre_condition do
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :etcd_host => '127.0.0.1',
      :etcd_port => 4001,
    }
  end

  let :params do
    {
    }
  end

  shared_examples 'neutron plugin vpp ml2' do
    before do
      params.merge!(default_params)
    end

    it 'configures ml2_vpp settings' do
      should contain_neutron_plugin_ml2('ml2_vpp/etcd_host').with_value(params[:etcd_host])
      should contain_neutron_plugin_ml2('ml2_vpp/etcd_port').with_value(params[:etcd_port])
      should contain_neutron_plugin_ml2('ml2_vpp/etcd_user').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('ml2_vpp/etcd_pass').with_value('<SERVICE DEFAULT>').with_secret(true)
    end

    context 'when enabling etcd authentication' do
      before :each do
        params.merge!(:etcd_user => 'admin',
                      :etcd_pass => 'password' )
      end
      it 'should configure etcd username and password' do
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_user').with_value('admin')
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_pass').with_value('password').with_secret(true)
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin vpp ml2'
    end
  end

end
