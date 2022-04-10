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

  let :params do
    {}
  end

  shared_examples 'neutron plugin vpp ml2' do

    context 'with defaults' do
      it 'configures ml2_vpp settings' do
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_host').with_value('<SERVICE DEFAULT>')
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_port').with_value('<SERVICE DEFAULT>')
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_user').with_value('<SERVICE DEFAULT>')
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_pass').with_value('<SERVICE DEFAULT>').with_secret(true)
        should contain_neutron_plugin_ml2('ml2_vpp/l3_hosts').with_value('<SERVICE DEFAULT>')
        should contain_neutron_plugin_ml2('ml2_vpp/enable_l3_ha').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters' do
      before :each do
        params.merge!({
          :etcd_host    => '127.0.0.1',
          :etcd_port    => 4001,
          :etcd_user    => 'admin',
          :etcd_pass    => 'password',
          :l3_hosts     => ['192.0.2.10', '192.0.2.11'],
          :enable_l3_ha => false,
        })
      end

      it 'configures ml2_vpp settings' do
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_host').with_value('127.0.0.1')
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_port').with_value(4001)
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_user').with_value('admin')
        should contain_neutron_plugin_ml2('ml2_vpp/etcd_pass').with_value('password').with_secret(true)
        should contain_neutron_plugin_ml2('ml2_vpp/l3_hosts').with_value('192.0.2.10,192.0.2.11')
        should contain_neutron_plugin_ml2('ml2_vpp/enable_l3_ha').with_value(false)
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
