require 'spec_helper'

describe 'neutron::plugins::ovs::opendaylight' do

  let :default_params do
    {
      :odl_check_url         => 'http://127.0.0.1:8080/restconf/operational/network-topology:network-topology/topology/netvirt:1',
      :odl_ovsdb_iface       => 'tcp:127.0.0.1:6640',
      :ovsdb_server_iface    => 'ptcp:6639:127.0.0.1',
      :provider_mappings     => [],
      :retry_interval        => 60,
      :retry_count           => 20,
      :host_id               => "dummy_host",
      :allowed_network_types => ['local', 'flat', 'vlan', 'vxlan', 'gre'],
      :enable_dpdk           => false,
      :vhostuser_socket_dir  => '/var/run/openvswitch',
      :vhostuser_mode        => 'server',
      :enable_hw_offload     => false,
      :enable_tls            => false,
    }
  end

  let :params do
    {
      :tunnel_ip          => '127.0.0.1',
      :odl_username       => 'user',
      :odl_password       => 'password',
    }
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
    }
  end


  shared_examples_for 'neutron plugin opendaylight ovs' do
    before do
      params.merge!(default_params)
    end

    context 'with provider mappings' do
      before do
        params.merge!({ :provider_mappings => ['default:br-ex'] })
      end
      it_configures 'with provider mappings'
    end

    context 'with DPDK enabled' do
      before do
        params.merge!({ :enable_dpdk => true })
      end
      it_configures 'with DPDK enabled'
    end

    context 'with hw_offload and  DPDK enabled' do
      before do
        params.merge!({ :enable_hw_offload => true, :enable_dpdk => true})
      end
      it_raises 'a Puppet::Error',/Enabling hardware offload and DPDK is not allowed/
    end

    it_configures 'with default parameters'

    context 'with TLS and no key or certificates' do
      before do
         params.merge!({ :enable_tls => true })
      end
      it_raises 'a Puppet::Error',/When enabling TLS, tls_key_file and tls_cert_file must be provided/
    end

    context 'with TLS and no CA cert' do
      before do
        File.stubs(:file?).returns(true)
        File.stubs(:readlines).returns(["MIIFGjCCBAKgAwIBAgICA"])
        params.merge!({
          :enable_tls => true,
          :tls_key_file => 'dummy.pem',
          :tls_cert_file => 'dummy.crt'})
      end
      it_configures 'with TLS enabled'
      it {is_expected.to contain_vs_ssl('system').with(
        'ensure'    => 'present',
        'key_file'  => 'dummy.pem',
        'cert_file' => 'dummy.crt',
        'bootstrap' => true,
        'before'    => 'Exec[Set OVS Manager to OpenDaylight]'
      )}
    end
    context 'with TLS and CA cert' do
      before do
        File.stubs(:file?).returns(true)
        File.stubs(:readlines).returns(["MIIFGjCCBAKgAwIBAgICA"])
        params.merge!({
          :enable_tls => true,
          :tls_key_file => 'dummy.pem',
          :tls_cert_file => 'dummy.crt',
          :tls_ca_cert_file => 'ca.crt'})
      end
      it_configures 'with TLS enabled'
      it {is_expected.to contain_vs_ssl('system').with(
        'ensure'    => 'present',
        'key_file'  => 'dummy.pem',
        'cert_file' => 'dummy.crt',
        'ca_file'   => 'ca.crt',
        'before'    => 'Exec[Set OVS Manager to OpenDaylight]'
      )}
    end
    context 'with TLS and multiple ODLs' do
      before do
        File.stubs(:file?).returns(true)
        File.stubs(:readlines).returns(["MIIFGjCCBAKgAwIBAgICA"])
        params.merge!({
          :enable_tls => true,
          :tls_key_file => 'dummy.pem',
          :tls_cert_file => 'dummy.crt',
          :odl_ovsdb_iface => 'tcp:127.0.0.1:6640 tcp:172.0.0.1:6640'})
      end
      it_configures 'with TLS and ODL HA'
      it {is_expected.to contain_vs_ssl('system').with(
        'ensure'    => 'present',
        'key_file'  => 'dummy.pem',
        'cert_file' => 'dummy.crt',
        'bootstrap' => true,
        'before'    => 'Exec[Set OVS Manager to OpenDaylight]'
      )}
    end
  end

  shared_examples_for 'with default parameters' do
    it 'configures OVS for ODL' do
      is_expected.to contain_exec('Wait for NetVirt OVSDB to come up')
      is_expected.to contain_exec('Set OVS Manager to OpenDaylight')
      is_expected.to contain_vs_config('other_config:local_ip')
      is_expected.not_to contain_vs_config('other_config:provider_mappings')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2')
    end
  end

  shared_examples_for 'with provider mappings' do
    it 'configures OVS for ODL' do
      is_expected.to contain_exec('Wait for NetVirt OVSDB to come up')
      is_expected.to contain_exec('Set OVS Manager to OpenDaylight')
      is_expected.to contain_vs_config('other_config:local_ip')
      is_expected.to contain_vs_config('other_config:provider_mappings')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2').with(
        :value => /bridge_mappings\": {\"default\":\"br-ex\"}/
      )
    end
  end

  shared_examples_for 'with DPDK enabled' do
    it 'configures OVS for ODL' do
      is_expected.to contain_exec('Wait for NetVirt OVSDB to come up')
      is_expected.to contain_exec('Set OVS Manager to OpenDaylight')
      is_expected.to contain_vs_config('other_config:local_ip')
      is_expected.not_to contain_vs_config('other_config:provider_mappings')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2').with(
        :value => /vhostuser/,
      )
    end
  end

  shared_examples_for 'with TLS enabled' do
    it 'configures OVS for ODL' do
      is_expected.to contain_exec('Add trusted cert: dummy.crt to https://127.0.0.1:8080')
      is_expected.to contain_exec('Set OVS Manager to OpenDaylight').with(
        :command => "ovs-vsctl set-manager pssl:6639:127.0.0.1 ssl:127.0.0.1:6640"
      )
      is_expected.to contain_vs_config('other_config:local_ip')
      is_expected.not_to contain_vs_config('other_config:provider_mappings')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2')
    end
  end

  shared_examples_for 'with TLS and ODL HA' do
    it 'configures OVS for ODL' do
      is_expected.to contain_exec('Add trusted cert: dummy.crt to https://172.0.0.1:8080')
      is_expected.to contain_exec('Add trusted cert: dummy.crt to https://127.0.0.1:8080')
      is_expected.to contain_exec('Set OVS Manager to OpenDaylight').with(
        :command => "ovs-vsctl set-manager pssl:6639:127.0.0.1 ssl:127.0.0.1:6640 ssl:172.0.0.1:6640"
      )
      is_expected.to contain_vs_config('other_config:local_ip')
      is_expected.not_to contain_vs_config('other_config:provider_mappings')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      is_expected.to contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2')
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7'
      }))
    end

    it_configures 'neutron plugin opendaylight ovs'
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
          :osfamily               => 'Debian'
      }))
    end

    it_configures 'neutron plugin opendaylight ovs'
  end
end
