require 'spec_helper'

describe 'neutron::plugins::ml2::fujitsu::fossw' do
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
      :fossw_ips              => '192.168.0.1,192.168.0.2',
      :username               => 'admin',
      :password               => 'admin',
      :port                   => 22,
      :timeout                => 30,
      :udp_dest_port          => 4789,
      :ovsdb_vlanid_range_min => 2,
      :ovsdb_port             => 6640,
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron fujitsu ml2 fossw plugin' do

    before do
      params.merge!(default_params)
    end

    it do
      should contain_neutron_plugin_ml2('fujitsu_fossw/fossw_ips').with_value(params[:fossw_ips])
      should contain_neutron_plugin_ml2('fujitsu_fossw/username').with_value(params[:username])
      should contain_neutron_plugin_ml2('fujitsu_fossw/password').with_value(params[:password]).with_secret(true)
      should contain_neutron_plugin_ml2('fujitsu_fossw/port').with_value(params[:port])
      should contain_neutron_plugin_ml2('fujitsu_fossw/timeout').with_value(params[:timeout])
      should contain_neutron_plugin_ml2('fujitsu_fossw/udp_dest_port').with_value(params[:udp_dest_port])
      should contain_neutron_plugin_ml2('fujitsu_fossw/ovsdb_vlanid_range_min').with_value(params[:ovsdb_vlanid_range_min])
      should contain_neutron_plugin_ml2('fujitsu_fossw/ovsdb_port').with_value(params[:ovsdb_port])
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron fujitsu ml2 fossw plugin'
    end
  end
end
