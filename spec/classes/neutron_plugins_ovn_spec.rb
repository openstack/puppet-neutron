require 'spec_helper'

describe 'neutron::plugins::ovn' do

  let :pre_condition do
    "class { 'neutron::server': auth_password => 'password' }
     class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
    {
       :ovsdb_connection => 'tcp:127.0.0.1:6641',
       :ovsdb_connection_timeout => '60',
       :neutron_sync_mode => 'log',
       :ovn_l3_mode => true,
       :vif_type => 'ovs',
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron ovn plugin' do

    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'should perform default configuration of' do
      is_expected.to contain_neutron_plugin_ovn('ovn/ovsdb_connection').with_value(params[:ovsdb_connection])
      is_expected.to contain_neutron_plugin_ovn('ovn/ovsdb_connection_timeout').with_value(params[:ovsdb_connection_timeout])
      is_expected.to contain_neutron_plugin_ovn('ovn/neutron_sync_mode').with_value(params[:neutron_sync_mode])
      is_expected.to contain_neutron_plugin_ovn('ovn/ovn_l3_mode').with_value(params[:ovn_l3_mode])
      is_expected.to contain_neutron_plugin_ovn('ovn/vif_type').with_value(params[:vif_type])
    end

  end

  shared_examples_for 'Validating parameters' do
    let :params do
      {}
    end

    before :each do
      params.clear
      params.merge!(default_params)
    end

    it 'should fail with undefined ovsdb_connection' do
      params.delete(:ovsdb_connection)
      is_expected.to raise_error(Puppet::Error)
    end

    it 'should fail with invalid neutron_sync_mode' do
      params[:neutron_sync_mode] = 'invalid'
      is_expected.to raise_error(Puppet::Error, /Invalid value for neutron_sync_mode parameter/)
    end

    it 'should fail with invalid vif_type' do
      params[:vif_type] = 'invalid'
      is_expected.to raise_error(Puppet::Error, /Invalid value for vif_type parameter/)
      params.delete(:vif_type)
      is_expected.to contain_neutron_plugin_ovn('ovn/vif_type').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'debian specific' do
    let :params do
      default_params
    end

    it 'configures /etc/default/neutron-server' do
      is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
        :path    => '/etc/default/neutron-server',
        :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/networking-ovn/networking-ovn.ini',
        :require => ['Package[neutron-server]', 'Package[neutron-plugin-ovn]'],
        :notify  => 'Service[neutron-server]')
    end
  end

  shared_examples_for 'redhat specific' do
    let :params do
      default_params
    end

    it 'should create plugin symbolic link' do
      is_expected.to contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/networking-ovn/networking-ovn.ini',
        :require => 'Package[python-networking-ovn]')
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({:processorcount => 8}))
      end

      case facts[:osfamily]
      when 'Debian'
        it_configures 'debian specific'
      when 'RedHat'
        it_configures 'redhat specific'
      end
      it_configures 'neutron ovn plugin'
      it_configures 'Validating parameters'
    end
  end
end
