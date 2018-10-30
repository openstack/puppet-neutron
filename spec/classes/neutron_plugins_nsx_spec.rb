require 'spec_helper'

describe 'neutron::plugins::nsx' do

  let :pre_condition do
    "class { 'neutron':
      core_plugin     => 'vmware_nsx.plugin.NsxV3Plugin' }
      class { '::neutron::keystone::authtoken':
        password => 'passw0rd',
      }
      class { 'neutron::server': }"
  end

  let :default_params do
  {
    :default_overlay_tz     => '<SERVICE DEFAULT>',
    :default_vlan_tz        => '<SERVICE DEFAULT>',
    :default_bridge_cluster => '<SERVICE DEFAULT>',
    :default_tier0_router   => '<SERVICE DEFAULT>',
    :nsx_api_managers       => '<SERVICE DEFAULT>',
    :nsx_api_user           => '<SERVICE DEFAULT>',
    :nsx_api_password       => '<SERVICE DEFAULT>',
    :dhcp_profile           => '<SERVICE DEFAULT>',
    :dhcp_relay_service     => '<SERVICE DEFAULT>',
    :metadata_proxy         => '<SERVICE DEFAULT>',
    :native_dhcp_metadata   => '<SERVICE DEFAULT>',
    :package_ensure         => 'present',
    :purge_config           => false,
  }
  end

  shared_examples_for 'neutron plugin nsx' do

    context 'with defaults' do
      it { is_expected.to contain_class('neutron::params') }

      it 'should have a nsx plugin ini file' do
        is_expected.to contain_file('/etc/neutron/plugins/vmware/nsx.ini').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'neutron',
          :mode   => '0640'
        )
      end

      it 'should configure neutron.conf' do
        is_expected.to contain_neutron_config('DEFAULT/core_plugin').with_value('vmware_nsx.plugin.NsxV3Plugin')
      end

      it 'passes purge to resource' do
        is_expected.to contain_resources('neutron_plugin_nsx').with({
          :purge => false
        })
      end

      it 'should configure nsx.ini' do
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_overlay_tz').with_value(default_params[:default_overlay_tz])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_vlan_tz').with_value(default_params[:default_vlan_tz])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_bridge_cluster').with_value(default_params[:default_bridge_cluster])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_tier0_router').with_value(default_params[:default_tier0_router])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/nsx_api_managers').with_value(default_params[:nsx_api_managers])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/nsx_api_password').with_value(default_params[:nsx_api_password])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/dhcp_profile').with_value(default_params[:dhcp_profile])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/dhcp_relay_service').with_value(default_params[:dhcp_relay_service])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/metadata_proxy').with_value(default_params[:metadata_proxy])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/native_dhcp_metadata').with_value(default_params[:native_dhcp_metadata])
      end
    end

    context 'with parameters' do
      let (:params) do
        {
          :default_overlay_tz     => 'fake-overlay-tz-uuid',
          :default_vlan_tz        => 'fake-vlan-tz-uuid',
          :default_bridge_cluster => 'fake-bridge-cluster-uuid',
          :default_tier0_router   => 'fake-tier0-uuid',
          :nsx_api_managers       => '127.0.0.1',
          :nsx_api_user           => 'admin',
          :nsx_api_password       => 'pasword',
          :dhcp_profile           => 'fake-dhcp-uuid',
          :dhcp_relay_service     => 'fake-dhcp-relay-service',
          :metadata_proxy         => 'fake-metadata-uuid',
          :native_dhcp_metadata   => 'True',
          :purge_config           => true,
        }
      end

      it {
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_overlay_tz').with_value(params[:default_overlay_tz])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_vlan_tz').with_value(params[:default_vlan_tz])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_bridge_cluster').with_value(params[:default_bridge_cluster])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/default_tier0_router').with_value(params[:default_tier0_router])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/nsx_api_managers').with_value(params[:nsx_api_managers])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/nsx_api_password').with_value(params[:nsx_api_password])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/dhcp_profile').with_value(params[:dhcp_profile])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/dhcp_relay_service').with_value(params[:dhcp_relay_service])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/metadata_proxy').with_value(params[:metadata_proxy])
        is_expected.to contain_neutron_plugin_nsx('nsx_v3/native_dhcp_metadata').with_value(params[:native_dhcp_metadata])
        is_expected.to contain_resources('neutron_plugin_nsx').with({
          :purge => true
        })
      }
    end

    context 'configure nsx with wrong core_plugin configure' do
      let :pre_condition do
        "class { 'neutron':
          core_plugin     => 'foo' }"
      end

      it_raises 'a Puppet::Error', /NSX plugin should be the core_plugin in neutron.conf/
    end
  end

  shared_examples_for 'neutron plugin nsx on Debian' do
    context 'with defaults' do
      it 'configures /etc/default/neutron-server' do
        is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
          :path    => '/etc/default/neutron-server',
          :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
          :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/vmware/nsx.ini',
        )
        is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_requires('Anchor[neutron::config::begin]')
        is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_notifies('Anchor[neutron::config::end]')
      end
    end
  end

  shared_examples_for 'neutron plugin nsx on RedHat' do
    context 'with defaults' do
     it 'should create plugin symbolic link' do
        is_expected.to contain_file('/etc/neutron/plugin.ini').with(
          :ensure  => 'link',
          :target  => '/etc/neutron/plugins/vmware/nsx.ini')
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

      it_configures 'neutron plugin nsx'
      it_configures "neutron plugin nsx on #{facts[:osfamily]}"
    end
  end

end
