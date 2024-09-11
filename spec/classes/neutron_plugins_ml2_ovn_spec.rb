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
      :ovn_nb_connection                    => '<SERVICE DEFAULT>',
      :ovn_sb_connection                    => '<SERVICE DEFAULT>',
      :ovn_nb_private_key                   => '<SERVICE DEFAULT>',
      :ovn_nb_certificate                   => '<SERVICE DEFAULT>',
      :ovn_nb_ca_cert                       => '<SERVICE DEFAULT>',
      :ovn_sb_private_key                   => '<SERVICE DEFAULT>',
      :ovn_sb_certificate                   => '<SERVICE DEFAULT>',
      :ovn_sb_ca_cert                       => '<SERVICE DEFAULT>',
      :ovsdb_connection_timeout             => '<SERVICE DEFAULT>',
      :ovsdb_retry_max_interval             => '<SERVICE DEFAULT>',
      :ovsdb_probe_interval                 => '<SERVICE DEFAULT>',
      :neutron_sync_mode                    => '<SERVICE DEFAULT>',
      :ovn_metadata_enabled                 => '<SERVICE DEFAULT>',
      :dvr_enabled                          => '<SERVICE DEFAULT>',
      :disable_ovn_dhcp_for_baremetal_ports => '<SERVICE DEFAULT>',
      :dns_servers                          => '<SERVICE DEFAULT>',
      :vhostuser_socket_dir                 => '<SERVICE DEFAULT>',
      :dhcp_default_lease_time              => '<SERVICE DEFAULT>',
      :ovn_dhcp4_global_options             => '<SERVICE DEFAULT>',
      :ovn_dhcp6_global_options             => '<SERVICE DEFAULT>',
      :ovn_emit_need_to_frag                => '<SERVICE DEFAULT>',
      :localnet_learn_fdb                   => '<SERVICE DEFAULT>',
      :fdb_age_threshold                    => '<SERVICE DEFAULT>',
      :mac_binding_age_threshold            => '<SERVICE DEFAULT>',
      :broadcast_arps_to_all_routers        => '<SERVICE DEFAULT>',
      :ovn_router_indirect_snat             => '<SERVICE DEFAULT>',
      :ignore_lsp_down                      => '<SERVICE DEFAULT>',
      :fdb_removal_limit                    => '<SERVICE DEFAULT>',
      :mac_binding_removal_limit            => '<SERVICE DEFAULT>',
      :network_log_rate_limit               => '<SERVICE DEFAULT>',
      :network_log_burst_limit              => '<SERVICE DEFAULT>',
      :network_log_local_output_log_base    => '<SERVICE DEFAULT>',
    }
  end

  shared_examples 'neutron::plugins::ml2::ovn' do

    let :params do
      {}
    end

    let :p do
      default_params.merge(params)
    end

    context 'with defaults' do
      it 'should configure defaults' do
        should contain_neutron_plugin_ml2('ovn/ovn_nb_connection').with_value(p[:ovn_nb_connection])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_connection').with_value(p[:ovn_sb_connection])
        should contain_neutron_plugin_ml2('ovn/ovn_nb_private_key').with_value(p[:ovn_nb_private_key])
        should contain_neutron_plugin_ml2('ovn/ovn_nb_certificate').with_value(p[:ovn_nb_certificate])
        should contain_neutron_plugin_ml2('ovn/ovn_nb_ca_cert').with_value(p[:ovn_nb_ca_cert])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_private_key').with_value(p[:ovn_sb_private_key])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_certificate').with_value(p[:ovn_sb_certificate])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_ca_cert').with_value(p[:ovn_sb_ca_cert])
        should contain_neutron_plugin_ml2('ovn/ovsdb_connection_timeout').with_value(p[:ovsdb_connection_timeout])
        should contain_neutron_plugin_ml2('ovn/ovsdb_retry_max_interval').with_value(p[:ovsdb_retry_max_interval])
        should contain_neutron_plugin_ml2('ovn/ovsdb_probe_interval').with_value(p[:ovsdb_probe_interval])
        should contain_neutron_plugin_ml2('ovn/neutron_sync_mode').with_value(p[:neutron_sync_mode])
        should contain_neutron_plugin_ml2('ovn/ovn_metadata_enabled').with_value(p[:ovn_metadata_enabled])
        should contain_neutron_plugin_ml2('ovn/enable_distributed_floating_ip').with_value(p[:dvr_enabled])
        should contain_neutron_plugin_ml2('ovn/disable_ovn_dhcp_for_baremetal_ports').with_value(p[:disable_ovn_dhcp_for_baremetal_ports])
        should contain_neutron_plugin_ml2('ovn/dns_servers').with_value(p[:dns_servers])
        should contain_neutron_plugin_ml2('ovn/vhost_sock_dir').with_value(p[:vhostuser_socket_dir])
        should contain_neutron_plugin_ml2('ovn/dhcp_default_lease_time').with_value(p[:dhcp_default_lease_time])
        should contain_neutron_plugin_ml2('ovn/ovn_dhcp4_global_options').with_value(p[:ovn_dhcp4_global_options])
        should contain_neutron_plugin_ml2('ovn/ovn_dhcp6_global_options').with_value(p[:ovn_dhcp6_global_options])
        should contain_neutron_plugin_ml2('ovn/ovn_emit_need_to_frag').with_value(p[:ovn_emit_need_to_frag])
        should contain_neutron_plugin_ml2('ovn/localnet_learn_fdb').with_value(p[:localnet_learn_fdb])
        should contain_neutron_plugin_ml2('ovn/fdb_age_threshold').with_value(p[:fdb_age_threshold])
        should contain_neutron_plugin_ml2('ovn/mac_binding_age_threshold').with_value(p[:mac_binding_age_threshold])
        should contain_neutron_plugin_ml2('ovn/broadcast_arps_to_all_routers').with_value(p[:broadcast_arps_to_all_routers])
        should contain_neutron_plugin_ml2('ovn/ovn_router_indirect_snat').with_value(p[:ovn_router_indirect_snat])
        should contain_neutron_plugin_ml2('ovn_nb_global/ignore_lsp_down').with_value(p[:ignore_lsp_down])
        should contain_neutron_plugin_ml2('ovn_nb_global/fdb_removal_limit').with_value(p[:fdb_removal_limit])
        should contain_neutron_plugin_ml2('ovn_nb_global/mac_binding_removal_limit').with_value(p[:mac_binding_removal_limit])
        should contain_neutron_plugin_ml2('network_log/rate_limit').with_value(p[:network_log_rate_limit])
        should contain_neutron_plugin_ml2('network_log/burst_limit').with_value(p[:network_log_burst_limit])
        should contain_neutron_plugin_ml2('network_log/local_output_log_base').with_value(p[:network_log_local_output_log_base])
      end
    end

    context 'with parameters' do
      let :params do
        {
          :ovn_nb_connection                    => 'tcp:127.0.0.1:6641',
          :ovn_sb_connection                    => 'tcp:127.0.0.1:6642',
          :ovn_nb_private_key                   => 'nb_key',
          :ovn_nb_certificate                   => 'nb_cert',
          :ovn_nb_ca_cert                       => 'nb_ca_cert',
          :ovn_sb_private_key                   => 'sb_key',
          :ovn_sb_certificate                   => 'sb_cert',
          :ovn_sb_ca_cert                       => 'sb_ca_cert',
          :ovsdb_connection_timeout             => 60,
          :ovsdb_retry_max_interval             => 180,
          :ovsdb_probe_interval                 => 60000,
          :neutron_sync_mode                    => 'log',
          :ovn_metadata_enabled                 => true,
          :dvr_enabled                          => false,
          :disable_ovn_dhcp_for_baremetal_ports => false,
          :dns_servers                          => '8.8.8.8,10.10.10.10',
          :vhostuser_socket_dir                 => '/var/run/openvswitch',
          :dhcp_default_lease_time              => 43200,
          :ovn_dhcp4_global_options             => 'ntp_server:1.2.3.4',
          :ovn_dhcp6_global_options             => 'ntp_server:5.6.7.8',
          :ovn_emit_need_to_frag                => false,
          :localnet_learn_fdb                   => false,
          :fdb_age_threshold                    => 10,
          :mac_binding_age_threshold            => 11,
          :broadcast_arps_to_all_routers        => true,
          :ovn_router_indirect_snat             => false,
          :ignore_lsp_down                      => false,
          :fdb_removal_limit                    => 12,
          :mac_binding_removal_limit            => 13,
        }
      end

      it 'should configure given values' do
        should contain_neutron_plugin_ml2('ovn/ovn_nb_connection').with_value(p[:ovn_nb_connection])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_connection').with_value(p[:ovn_sb_connection])
        should contain_neutron_plugin_ml2('ovn/ovn_nb_private_key').with_value(p[:ovn_nb_private_key])
        should contain_neutron_plugin_ml2('ovn/ovn_nb_certificate').with_value(p[:ovn_nb_certificate])
        should contain_neutron_plugin_ml2('ovn/ovn_nb_ca_cert').with_value(p[:ovn_nb_ca_cert])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_private_key').with_value(p[:ovn_sb_private_key])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_certificate').with_value(p[:ovn_sb_certificate])
        should contain_neutron_plugin_ml2('ovn/ovn_sb_ca_cert').with_value(p[:ovn_sb_ca_cert])
        should contain_neutron_plugin_ml2('ovn/ovsdb_connection_timeout').with_value(p[:ovsdb_connection_timeout])
        should contain_neutron_plugin_ml2('ovn/ovsdb_retry_max_interval').with_value(p[:ovsdb_retry_max_interval])
        should contain_neutron_plugin_ml2('ovn/ovsdb_probe_interval').with_value(p[:ovsdb_probe_interval])
        should contain_neutron_plugin_ml2('ovn/neutron_sync_mode').with_value(p[:neutron_sync_mode])
        should contain_neutron_plugin_ml2('ovn/ovn_metadata_enabled').with_value(p[:ovn_metadata_enabled])
        should contain_neutron_plugin_ml2('ovn/enable_distributed_floating_ip').with_value(p[:dvr_enabled])
        should contain_neutron_plugin_ml2('ovn/disable_ovn_dhcp_for_baremetal_ports').with_value(p[:disable_ovn_dhcp_for_baremetal_ports])
        should contain_neutron_plugin_ml2('ovn/dns_servers').with_value(p[:dns_servers])
        should contain_neutron_plugin_ml2('ovn/vhost_sock_dir').with_value(p[:vhostuser_socket_dir])
        should contain_neutron_plugin_ml2('ovn/dhcp_default_lease_time').with_value(p[:dhcp_default_lease_time])
        should contain_neutron_plugin_ml2('ovn/ovn_dhcp4_global_options').with_value(p[:ovn_dhcp4_global_options])
        should contain_neutron_plugin_ml2('ovn/ovn_dhcp6_global_options').with_value(p[:ovn_dhcp6_global_options])
        should contain_neutron_plugin_ml2('ovn/ovn_emit_need_to_frag').with_value(p[:ovn_emit_need_to_frag])
        should contain_neutron_plugin_ml2('ovn/localnet_learn_fdb').with_value(p[:localnet_learn_fdb])
        should contain_neutron_plugin_ml2('ovn/fdb_age_threshold').with_value(p[:fdb_age_threshold])
        should contain_neutron_plugin_ml2('ovn/mac_binding_age_threshold').with_value(p[:mac_binding_age_threshold])
        should contain_neutron_plugin_ml2('ovn/broadcast_arps_to_all_routers').with_value(p[:broadcast_arps_to_all_routers])
        should contain_neutron_plugin_ml2('ovn/ovn_router_indirect_snat').with_value(p[:ovn_router_indirect_snat])
        should contain_neutron_plugin_ml2('ovn_nb_global/ignore_lsp_down').with_value(p[:ignore_lsp_down])
        should contain_neutron_plugin_ml2('ovn_nb_global/fdb_removal_limit').with_value(p[:fdb_removal_limit])
        should contain_neutron_plugin_ml2('ovn_nb_global/mac_binding_removal_limit').with_value(p[:mac_binding_removal_limit])
        should contain_neutron_plugin_ml2('network_log/rate_limit').with_value(p[:network_log_rate_limit])
        should contain_neutron_plugin_ml2('network_log/burst_limit').with_value(p[:network_log_burst_limit])
        should contain_neutron_plugin_ml2('network_log/local_output_log_base').with_value(p[:network_log_local_output_log_base])
      end
    end

    context 'with invalid neutron_sync_mode' do
      let :params do
        {
          :neutron_sync_mode => 'invalid'
        }
      end

      it {
        should raise_error(Puppet::Error, /Invalid value for neutron_sync_mode parameter/)
      }
    end

    context 'with parameters set by arrays' do
      let :params do
        {
          :ovn_nb_connection        => ['tcp:192.0.2.11:6641', 'tcp:192.0.2.12:6641'],
          :ovn_sb_connection        => ['tcp:192.0.2.11:6642', 'tcp:192.0.2.12:6642'],
          :dns_servers              => ['8.8.8.8', '10.10.10.10'],
          :ovn_dhcp4_global_options => ['ntp_server:1.2.3.4', 'wpad:1.2.3.5'],
          :ovn_dhcp6_global_options => ['ntp_server:5.6.7.8', 'wpad:5.6.7.9'],
        }
      end

      it 'should configure comma-separated strings' do
        should contain_neutron_plugin_ml2('ovn/ovn_nb_connection').with_value(p[:ovn_nb_connection].join(','))
        should contain_neutron_plugin_ml2('ovn/ovn_sb_connection').with_value(p[:ovn_sb_connection].join(','))
        should contain_neutron_plugin_ml2('ovn/dns_servers').with_value(p[:dns_servers].join(','))
        should contain_neutron_plugin_ml2('ovn/ovn_dhcp4_global_options').with_value(p[:ovn_dhcp4_global_options].join(','))
        should contain_neutron_plugin_ml2('ovn/ovn_dhcp6_global_options').with_value(p[:ovn_dhcp6_global_options].join(','))
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::plugins::ml2::ovn'
    end
  end
end
