require 'spec_helper_acceptance'

describe 'basic neutron_config resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      File <||> -> Neutron_config <||>
      File <||> -> Neutron_api_config <||>
      File <||> -> Neutron_dhcp_agent_config <||>
      File <||> -> Neutron_fwaas_service_config <||>
      File <||> -> Neutron_l3_agent_config <||>
      File <||> -> Neutron_lbaas_agent_config <||>
      File <||> -> Neutron_metadata_agent_config <||>
      File <||> -> Neutron_metering_agent_config <||>
      File <||> -> Neutron_plugin_cisco <||>
      File <||> -> Neutron_plugin_cisco_credentials <||>
      File <||> -> Neutron_plugin_cisco_db_conn <||>
      File <||> -> Neutron_plugin_cisco_l2network <||>
      File <||> -> Neutron_plugin_linuxbridge <||>
      File <||> -> Neutron_plugin_ml2 <||>
      File <||> -> Neutron_plugin_nvp <||>
      File <||> -> Neutron_vpnaas_agent_config <||>
      File <||> -> Neutron_plugin_midonet <||>
      File <||> -> Neutron_plugin_opencontrail <||>
      File <||> -> Neutron_agent_linuxbridge <||>
      File <||> -> Neutron_agent_ovs <||>
      File <||> -> Neutron_plugin_plumgrid <||>
      File <||> -> Neutron_plumlib_plumgrid <||>
      File <||> -> Neutron_plugin_sriov <||>
      File <||> -> Neutron_sriov_agent_config <||>

      $neutron_directories = ['/etc/neutron',
                              '/etc/neutron/plugins',
                              '/etc/neutron/plugins/cisco',
                              '/etc/neutron/plugins/linuxbridge',
                              '/etc/neutron/plugins/ml2',
                              '/etc/neutron/plugins/nicira',
                              '/etc/neutron/plugins/midonet',
                              '/etc/neutron/plugins/opencontrail',
                              '/etc/neutron/plugins/plumgrid']

      $neutron_files = [ '/etc/neutron/api-paste.ini',
                         '/etc/neutron/neutron.conf',
                         '/etc/neutron/dhcp_agent.ini',
                         '/etc/neutron/fwaas_driver.ini',
                         '/etc/neutron/l3_agent.ini',
                         '/etc/neutron/lbaas_agent.ini',
                         '/etc/neutron/metadata_agent.ini',
                         '/etc/neutron/metering_agent.ini',
                         '/etc/neutron/plugins/cisco/cisco_plugins.ini',
                         '/etc/neutron/plugins/cisco/credentials.ini',
                         '/etc/neutron/plugins/cisco/db_conn.ini',
                         '/etc/neutron/plugins/cisco/l2network_plugin.ini',
                         '/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini',
                         '/etc/neutron/plugins/ml2/ml2_conf.ini',
                         '/etc/neutron/plugins/nicira/nvp.ini',
                         '/etc/neutron/vpn_agent.ini',
                         '/etc/neutron/plugins/midonet/midonet.ini',
                         '/etc/neutron/plugins/opencontrail/ContrailPlugin.ini',
                         '/etc/neutron/plugins/plumgrid/plumgrid.ini',
                         '/etc/neutron/plugins/ml2/ml2_conf_sriov.ini',
                         '/etc/neutron/plugins/ml2/sriov_agent.ini']

      file { $neutron_directories :
        ensure => directory,
      }

      file { $neutron_files :
        ensure => file,
      }

      neutron_api_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_api_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_api_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_api_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_dhcp_agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_dhcp_agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_dhcp_agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_dhcp_agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_fwaas_service_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_fwaas_service_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_fwaas_service_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_fwaas_service_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_l3_agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_l3_agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_l3_agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_l3_agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_lbaas_agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_lbaas_agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_lbaas_agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_lbaas_agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_metadata_agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_metadata_agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_metadata_agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_metadata_agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_metering_agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_metering_agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_metering_agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_metering_agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_cisco { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_cisco { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco_credentials { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_cisco_credentials { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_cisco_credentials { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco_credentials { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco_db_conn { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_cisco_db_conn { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_cisco_db_conn { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco_db_conn { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco_l2network { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_cisco_l2network { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_cisco_l2network { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_cisco_l2network { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_linuxbridge { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_linuxbridge { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_linuxbridge { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_linuxbridge { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_ml2 { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_ml2 { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_ml2 { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_ml2 { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_nvp { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_nvp { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_nvp { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_nvp { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_vpnaas_agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_vpnaas_agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_vpnaas_agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_vpnaas_agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_midonet { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_midonet { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_midonet { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_midonet { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_opencontrail { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_opencontrail { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_opencontrail { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_opencontrail { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_agent_linuxbridge { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_agent_linuxbridge { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_agent_linuxbridge { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_agent_linuxbridge { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_agent_ovs { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_agent_ovs { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_agent_ovs { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_agent_ovs { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_plumgrid { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_plumgrid { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_plumgrid { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_plumgrid { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plumlib_plumgrid { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plumlib_plumgrid { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plumlib_plumgrid { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto', }

      neutron_plumlib_plumgrid { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_sriov { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_plugin_sriov { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_plugin_sriov { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_plugin_sriov { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_sriov_agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_sriov_agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_sriov_agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_sriov_agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      neutron_lbaas_service_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      neutron_lbaas_service_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      neutron_lbaas_service_config { 'DEFAULT/thisshouldexist3' :
        value => ['value1', 'value2'],
      }

      neutron_lbaas_service_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      neutron_lbaas_service_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    $neutron_files = [ '/etc/neutron/api-paste.ini',
                       '/etc/neutron/neutron.conf',
                       '/etc/neutron/dhcp_agent.ini',
                       '/etc/neutron/fwaas_driver.ini',
                       '/etc/neutron/l3_agent.ini',
                       '/etc/neutron/lbaas_agent.ini',
                       '/etc/neutron/metadata_agent.ini',
                       '/etc/neutron/metering_agent.ini',
                       '/etc/neutron/plugins/cisco/cisco_plugins.ini',
                       '/etc/neutron/plugins/cisco/credentials.ini',
                       '/etc/neutron/plugins/cisco/db_conn.ini',
                       '/etc/neutron/plugins/cisco/l2network_plugin.ini',
                       '/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini',
                       '/etc/neutron/plugins/ml2/ml2_conf.ini',
                       '/etc/neutron/plugins/nicira/nvp.ini',
                       '/etc/neutron/vpn_agent.ini',
                       '/etc/neutron/plugins/midonet/midonet.ini',
                       '/etc/neutron/plugins/opencontrail/ContrailPlugin.ini',
                       '/etc/neutron/plugins/plumgrid/plumgrid.ini',
                       '/etc/neutron/plugins/ml2/ml2_conf_sriov.ini',
                       '/etc/neutron/plugins/ml2/sriov_agent.ini',
                       '/etc/neutron/neutron_lbaas.conf']

    $neutron_files.each do |neutron_conf_file|
      describe file(neutron_conf_file) do
        it { is_expected.to exist }
        it { is_expected.to contain('thisshouldexist=foo') }
        it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }

        describe '#content' do
          subject { super().content }
          it { is_expected.to_not match /thisshouldnotexist/ }
        end
      end
    end

    describe file('/etc/neutron/neutron_lbaas.conf') do
      it { is_expected.to contain('thisshouldexist3=value1') }
      it { is_expected.to contain('thisshouldexist3=value2') }
    end

  end
end
