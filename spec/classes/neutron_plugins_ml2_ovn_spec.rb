require 'spec_helper'

describe 'neutron::plugins::ml2::ovn' do
  let :pre_condition do
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron': }"
  end

  let :default_params do
    {
       :ovn_nb_connection        => 'tcp:127.0.0.1:6641',
       :ovn_sb_connection        => 'tcp:127.0.0.1:6642',
       :ovn_nb_private_key       => 'nb_key',
       :ovn_nb_certificate       => 'nb_cert',
       :ovn_nb_ca_cert           => 'nb_ca_cert',
       :ovn_sb_private_key       => 'sb_key',
       :ovn_sb_certificate       => 'sb_cert',
       :ovn_sb_ca_cert           => 'sb_ca_cert',
       :ovsdb_connection_timeout => 60,
       :ovsdb_retry_max_interval => 180,
       :ovsdb_probe_interval     => 60000,
       :neutron_sync_mode        => 'log',
       :dvr_enabled              => false,
       :dns_servers              => ['8.8.8.8', '10.10.10.10'],
       :ovn_emit_need_to_frag    => false,
    }
  end

  shared_examples 'neutron ovn plugin' do

    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'should perform default configuration of' do
      should contain_neutron_plugin_ml2('ovn/ovn_nb_connection').with_value(params[:ovn_nb_connection])
      should contain_neutron_plugin_ml2('ovn/ovn_sb_connection').with_value(params[:ovn_sb_connection])
      should contain_neutron_plugin_ml2('ovn/ovn_nb_private_key').with_value(params[:ovn_nb_private_key])
      should contain_neutron_plugin_ml2('ovn/ovn_nb_certificate').with_value(params[:ovn_nb_certificate])
      should contain_neutron_plugin_ml2('ovn/ovn_nb_ca_cert').with_value(params[:ovn_nb_ca_cert])
      should contain_neutron_plugin_ml2('ovn/ovn_sb_private_key').with_value(params[:ovn_sb_private_key])
      should contain_neutron_plugin_ml2('ovn/ovn_sb_certificate').with_value(params[:ovn_sb_certificate])
      should contain_neutron_plugin_ml2('ovn/ovn_sb_ca_cert').with_value(params[:ovn_sb_ca_cert])
      should contain_neutron_plugin_ml2('ovn/ovsdb_connection_timeout').with_value(params[:ovsdb_connection_timeout])
      should contain_neutron_plugin_ml2('ovn/ovsdb_retry_max_interval').with_value(params[:ovsdb_retry_max_interval])
      should contain_neutron_plugin_ml2('ovn/ovsdb_probe_interval').with_value(params[:ovsdb_probe_interval])
      should contain_neutron_plugin_ml2('ovn/neutron_sync_mode').with_value(params[:neutron_sync_mode])
      should contain_neutron_plugin_ml2('ovn/enable_distributed_floating_ip').with_value(params[:dvr_enabled])
      should contain_neutron_plugin_ml2('ovn/dns_servers').with_value(params[:dns_servers].join(','))
      should contain_neutron_plugin_ml2('ovn/vhost_sock_dir').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('ovn/ovn_emit_need_to_frag').with_value(params[:ovn_emit_need_to_frag])
      should contain_neutron_plugin_ml2('network_log/rate_limit').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('network_log/burst_limit').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('network_log/local_output_log_base').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples 'Validating parameters' do
    let :params do
      {}
    end

    before :each do
      params.clear
      params.merge!(default_params)
      params.merge!(:vhostuser_socket_dir => 'test')
    end

    it 'should fail with invalid neutron_sync_mode' do
      params[:neutron_sync_mode] = 'invalid'
      should raise_error(Puppet::Error, /Invalid value for neutron_sync_mode parameter/)
    end

    it 'should contain valid vhostuser socket dir' do
      should contain_neutron_plugin_ml2('ovn/vhost_sock_dir').with_value('test')
    end

    context 'with DVR' do
      before :each do
        params.merge!(:dvr_enabled => true)
      end
      it 'should enable DVR mode' do
        should contain_neutron_plugin_ml2('ovn/enable_distributed_floating_ip').with_value(params[:dvr_enabled])
      end
    end

    context 'with emit need to fragment enabled' do
      before :each do
        params.merge!(:ovn_emit_need_to_frag => true)
      end
      it 'should enable emit need to fragment option' do
        should contain_neutron_plugin_ml2('ovn/ovn_emit_need_to_frag').with_value(params[:ovn_emit_need_to_frag])
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({:processorcount => 8}))
      end

      it_behaves_like 'neutron ovn plugin'
      it_behaves_like 'Validating parameters'
    end
  end
end
