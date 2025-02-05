require 'spec_helper_acceptance'

describe 'basic neutron_config resource' do

  neutron_files = [ '/etc/neutron/api-paste.ini',
                     '/etc/neutron/neutron.conf',
                     '/etc/neutron/dhcp_agent.ini',
                     '/etc/neutron/l3_agent.ini',
                     '/etc/neutron/metadata_agent.ini',
                     '/etc/neutron/metering_agent.ini',
                     '/etc/neutron/l2gw_plugin.ini',
                     '/etc/neutron/l2gateway_agent.ini',
                     '/etc/neutron/plugins/ml2/ml2_conf.ini',
                     '/etc/neutron/vpn_agent.ini',
                     '/etc/neutron/neutron_vpnaas.conf',
                     '/etc/neutron/ovn_vpn_agent.ini',
                     '/etc/neutron/taas_plugin.ini',
                     '/etc/neutron/plugins/ml2/openvswitch_agent.ini',
                     '/etc/neutron/plugins/ml2/ovn_agent.ini',
                     '/etc/neutron/plugins/ml2/sriov_agent.ini',
                     '/etc/neutron/neutron_ovn_metadata_agent.ini']

  pp= <<-EOS
  Exec { logoutput => 'on_failure' }

  File <||> -> Neutron_config <||>
  File <||> -> Neutron_api_paste_ini <||>
  File <||> -> Neutron_dhcp_agent_config <||>
  File <||> -> Neutron_l3_agent_config <||>
  File <||> -> Neutron_metadata_agent_config <||>
  File <||> -> Neutron_metering_agent_config <||>
  File <||> -> Neutron_plugin_ml2 <||>
  File <||> -> Neutron_l2gw_service_config <||>
  File <||> -> Neutron_vpnaas_agent_config <||>
  File <||> -> Neutron_vpnaas_service_config <||>
  File <||> -> Neutron_ovn_vpn_agent_config <||>
  File <||> -> Neutron_taas_service_config <||>
  File <||> -> Neutron_agent_ovs <||>
  File <||> -> Neutron_agent_ovn <||>
  File <||> -> Neutron_sriov_agent_config <||>
  File <||> -> Neutron_l2gw_agent_config <||>
  File <||> -> Ovn_metadata_agent_config <||>


  $neutron_directories = ['/etc/neutron',
                          '/etc/neutron/plugins',
                          '/etc/neutron/plugins/ml2']

  $neutron_files = [ '/etc/neutron/api-paste.ini',
                     '/etc/neutron/neutron.conf',
                     '/etc/neutron/dhcp_agent.ini',
                     '/etc/neutron/l3_agent.ini',
                     '/etc/neutron/metadata_agent.ini',
                     '/etc/neutron/metering_agent.ini',
                     '/etc/neutron/l2gw_plugin.ini',
                     '/etc/neutron/l2gateway_agent.ini',
                     '/etc/neutron/plugins/ml2/ml2_conf.ini',
                     '/etc/neutron/vpn_agent.ini',
                     '/etc/neutron/neutron_vpnaas.conf',
                     '/etc/neutron/ovn_vpn_agent.ini',
                     '/etc/neutron/taas_plugin.ini',
                     '/etc/neutron/plugins/ml2/openvswitch_agent.ini',
                     '/etc/neutron/plugins/ml2/ovn_agent.ini',
                     '/etc/neutron/plugins/ml2/sriov_agent.ini',
                     '/etc/neutron/neutron_ovn_metadata_agent.ini']

  file { $neutron_directories :
    ensure => directory,
  }

  file { $neutron_files :
    ensure => file,
  }

  neutron_api_paste_ini { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  neutron_api_paste_ini { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  neutron_api_paste_ini { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  neutron_api_paste_ini { 'DEFAULT/thisshouldnotexist2' :
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

  neutron_vpnaas_service_config { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  neutron_vpnaas_service_config { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  neutron_vpnaas_service_config { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  neutron_vpnaas_service_config { 'DEFAULT/thisshouldnotexist2' :
    value             => 'toto',
    ensure_absent_val => 'toto',
  }

  neutron_ovn_vpn_agent_config { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  neutron_ovn_vpn_agent_config { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  neutron_ovn_vpn_agent_config { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  neutron_ovn_vpn_agent_config { 'DEFAULT/thisshouldnotexist2' :
    value             => 'toto',
    ensure_absent_val => 'toto',
  }

  neutron_taas_service_config { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  neutron_taas_service_config { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  neutron_taas_service_config { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  neutron_taas_service_config { 'DEFAULT/thisshouldnotexist2' :
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

  neutron_agent_ovn { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  neutron_agent_ovn { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  neutron_agent_ovn { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  neutron_agent_ovn { 'DEFAULT/thisshouldnotexist2' :
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

  neutron_l2gw_service_config { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  neutron_l2gw_service_config { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  neutron_l2gw_service_config { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  neutron_l2gw_service_config { 'DEFAULT/thisshouldnotexist2' :
    value             => 'toto',
    ensure_absent_val => 'toto',
  }

  neutron_l2gw_agent_config { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  neutron_l2gw_agent_config { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  neutron_l2gw_agent_config { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  neutron_l2gw_agent_config { 'DEFAULT/thisshouldnotexist2' :
    value             => 'toto',
    ensure_absent_val => 'toto',
  }

  ovn_metadata_agent_config { 'DEFAULT/thisshouldexist' :
    value => 'foo',
  }

  ovn_metadata_agent_config { 'DEFAULT/thisshouldnotexist' :
    value => '<SERVICE DEFAULT>',
  }

  ovn_metadata_agent_config { 'DEFAULT/thisshouldexist2' :
    value             => '<SERVICE DEFAULT>',
    ensure_absent_val => 'toto',
  }

  ovn_metadata_agent_config { 'DEFAULT/thisshouldnotexist2' :
    value             => 'toto',
    ensure_absent_val => 'toto',
  }

  EOS

  resource_names = ['neutron_api_paste_ini',
                    'neutron_config',
                    'neutron_dhcp_agent_config',
                    'neutron_l3_agent_config',
                    'neutron_metadata_agent_config',
                    'neutron_metering_agent_config',
                    'neutron_plugin_ml2',
                    'neutron_vpnaas_agent_config',
                    'neutron_vpnaas_service_config',
                    'neutron_ovn_vpn_agent_config',
                    'neutron_taas_service_config',
                    'neutron_agent_ovs',
                    'neutron_agent_ovn',
                    'neutron_sriov_agent_config',
                    'neutron_l2gw_service_config',
                    'neutron_l2gw_agent_config',
                    'ovn_metadata_agent_config']

  pp_resource_names = "  $resource_names = [" + resource_names.collect { |r| "    '#{r}'," }.join("\n") + "   ]\n"

  pp_purge = pp + pp_resource_names + <<-EOS

  resources { $resource_names:
    purge => true,
  }

  EOS

  bogus_config = <<-EOS
   $junk = {'DEFAULT/xyz_unsupported_value_123' => { value => false },
            'DEFAULT/xyz_unsupported_value_569' => { value => 'some_string' }
            }
  EOS

  pp_bogus_config = bogus_config + resource_names.collect { |r| "  create_resources('#{r}', $junk)" }.join("\n")

  context 'with default parameters' do
    # Run it twice and test for idempotency
    before :all do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
    neutron_files.each do |neutron_conf_file|
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
  end

  context 'purge unmanaged resources' do
    before :all do
      apply_manifest(pp_bogus_config, :catch_failures => true)
      apply_manifest(pp_purge, :catch_failures => true)
    end

    neutron_files.each do |neutron_conf_file|
      describe file(neutron_conf_file) do
        it { is_expected.to exist }
        it { is_expected.to contain('thisshouldexist=foo') }
        it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }

        describe '#content' do
          subject { super().content }
          it { is_expected.to_not match /thisshouldnotexist/ }
          it { is_expected.to_not match /xyz_unsupported_value/ }
        end
      end
    end
  end

end
