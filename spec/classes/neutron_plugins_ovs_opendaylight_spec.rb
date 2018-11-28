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
      :enable_ipv6           => false,
    }
  end

  let :params do
    {
      :tunnel_ip          => '127.0.0.1',
      :odl_username       => 'user',
      :odl_password       => 'password',
    }
  end

  shared_examples 'neutron plugin opendaylight ovs' do
    before do
      params.merge!(default_params)
    end

    context 'with provider mappings' do
      before do
        params.merge!({ :provider_mappings => ['default:br-ex'] })
      end
      it_behaves_like 'with provider mappings'
    end

    context 'with DPDK enabled' do
      before do
        params.merge!({ :enable_dpdk => true })
      end
      it_behaves_like 'with DPDK enabled'
    end

    context 'with hw_offload and  DPDK enabled' do
      before do
        params.merge!({ :enable_hw_offload => true, :enable_dpdk => true})
      end

      it { should raise_error(Puppet::Error, /Enabling hardware offload and DPDK is not allowed/) }
    end

    it_behaves_like 'with default parameters'

    context 'with TLS and no key or certificates' do
      before do
         params.merge!({ :enable_tls => true })
      end

      it { should raise_error(Puppet::Error, /When enabling TLS, tls_key_file and tls_cert_file must be provided/) }
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
      it_behaves_like 'with TLS enabled'
      it {should contain_vs_ssl('system').with(
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
      it_behaves_like 'with TLS enabled'
      it {should contain_vs_ssl('system').with(
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
          :odl_ovsdb_iface => 'ssl:127.0.0.1:6640 ssl:172.0.0.1:6640'})
      end

      it_behaves_like 'with TLS and ODL HA'
      it {should contain_vs_ssl('system').with(
        'ensure'    => 'present',
        'key_file'  => 'dummy.pem',
        'cert_file' => 'dummy.crt',
        'bootstrap' => true,
        'before'    => 'Exec[Set OVS Manager to OpenDaylight]'
      )}
    end

    context 'with IPv6 enabled' do
      before do
        params.merge!({
          :enable_ipv6 => true,
          :odl_ovsdb_iface => 'tcp:[::1]:6640',
        })
      end

      it_behaves_like 'with IPv6 enabled'
    end
  end

  shared_examples 'with default parameters' do
    it 'configures OVS for ODL' do
      should contain_exec('Wait for NetVirt OVSDB to come up')
      should contain_exec('Set OVS Manager to OpenDaylight')
      should contain_vs_config('other_config:local_ip')
      should_not contain_vs_config('other_config:provider_mappings')
      should contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      should contain_vs_config('external_ids:hostname')
      should contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2')
    end
  end

  shared_examples 'with provider mappings' do
    it 'configures OVS for ODL' do
      should contain_exec('Wait for NetVirt OVSDB to come up')
      should contain_exec('Set OVS Manager to OpenDaylight')
      should contain_vs_config('other_config:local_ip')
      should contain_vs_config('other_config:provider_mappings')
      should contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      should contain_vs_config('external_ids:hostname')
      should contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2').with(
        :value => /bridge_mappings\": {\"default\":\"br-ex\"}/
      )
    end
  end

  shared_examples 'with DPDK enabled' do
    it 'configures OVS for ODL' do
      should contain_exec('Wait for NetVirt OVSDB to come up')
      should contain_exec('Set OVS Manager to OpenDaylight')
      should contain_vs_config('other_config:local_ip')
      should_not contain_vs_config('other_config:provider_mappings')
      should contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      should contain_vs_config('external_ids:hostname')
      should contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2').with(
        :value => /vhostuser/,
      )
    end
  end

  shared_examples 'with TLS enabled' do
    before do
        params.merge!({ :odl_ovsdb_iface  => 'ssl:127.0.0.1:6640' })
    end
    it 'configures OVS for ODL' do
      should contain_exec('Add trusted cert: dummy.crt to https://127.0.0.1:8080')
      should contain_exec('Set OVS Manager to OpenDaylight').with(
        :command => "ovs-vsctl set-manager pssl:6639:127.0.0.1 ssl:127.0.0.1:6640"
      )
      should contain_vs_config('other_config:local_ip')
      should_not contain_vs_config('other_config:provider_mappings')
      should contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      should contain_vs_config('external_ids:hostname')
      should contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2')
    end
  end

  shared_examples 'with TLS and ODL HA' do
    it 'configures OVS for ODL' do
      should contain_exec('Add trusted cert: dummy.crt to https://172.0.0.1:8080')
      should contain_exec('Add trusted cert: dummy.crt to https://127.0.0.1:8080')
      should contain_exec('Set OVS Manager to OpenDaylight').with(
        :command => "ovs-vsctl set-manager pssl:6639:127.0.0.1 ssl:127.0.0.1:6640 ssl:172.0.0.1:6640"
      )
      should contain_vs_config('other_config:local_ip')
      should_not contain_vs_config('other_config:provider_mappings')
      should contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      should contain_vs_config('external_ids:hostname')
      should contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2')
    end
  end

  shared_examples 'with IPv6 enabled' do
    it 'configures OVS for ODL' do
      should contain_exec('Wait for NetVirt OVSDB to come up')
      should contain_exec('Set OVS Manager to OpenDaylight').with(
        :command => "ovs-vsctl set-manager ptcp:6639:[::1] tcp:[::1]:6640"
      )
      should contain_vs_config('other_config:local_ip')
      should_not contain_vs_config('other_config:provider_mappings')
      should contain_vs_config('external_ids:odl_os_hostconfig_hostid')
      should contain_vs_config('external_ids:hostname')
      should contain_vs_config('external_ids:odl_os_hostconfig_config_odl_l2')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin opendaylight ovs'
    end
  end
end
