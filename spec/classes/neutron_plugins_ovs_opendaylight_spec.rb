require 'spec_helper'

describe 'neutron::plugins::ovs::opendaylight' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :odl_username       => 'admin',
      :odl_password       => 'admin',
      :odl_check_url      => 'http://127.0.0.1:8080/restconf/operational/network-topology:network-topology/topology/netvirt:1',
      :odl_ovsdb_iface    => 'tcp:127.0.0.1:6640',
      :ovsdb_server_iface => 'ptcp:6639:127.0.0.1',
      :provider_mappings  => [],
      :retry_interval     => 60,
      :retry_count        => 20,
    }
  end

  let :params do
    {
      :tunnel_ip         => '127.0.0.1',
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
    it_configures 'with default parameters'
  end

  shared_examples_for 'with default parameters' do
    it 'configures OVS for ODL' do
      is_expected.to contain_exec('Wait for NetVirt OVSDB to come up')
      is_expected.to contain_exec('Set OVS Manager to OpenDaylight')
      is_expected.to contain_exec('Set local_ip Other Option')
      is_expected.not_to contain_exec('Set provider_mappings Other Option')
    end
  end

  shared_examples_for 'with provider mappings' do
    it 'configures OVS for ODL' do
      is_expected.to contain_exec('Wait for NetVirt OVSDB to come up')
      is_expected.to contain_exec('Set OVS Manager to OpenDaylight')
      is_expected.to contain_exec('Set local_ip Other Option')
      is_expected.to contain_exec('Set provider_mappings Other Option')
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
