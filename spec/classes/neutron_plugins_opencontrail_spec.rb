require 'spec_helper'

describe 'neutron::plugins::opencontrail' do
  shared_examples 'neutron::plugins::contrail' do
    let :params do
      {
        :api_server_ip       => '10.0.0.1',
        :api_server_port     => '8082',
        :contrail_extensions => ['ipam:ipam','policy:policy','route-table'],
        :purge_config        => false,
      }
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_plugin_opencontrail').with({
        :purge => false
      })
    end

    it 'should perform default configuration of' do
      should contain_neutron_plugin_opencontrail('APISERVER/api_server_ip').with_value(params[:api_server_ip])
      should contain_neutron_plugin_opencontrail('APISERVER/api_server_port').with_value(params[:api_server_port])
      should contain_neutron_plugin_opencontrail('APISERVER/contrail_extensions').with_value(params[:contrail_extensions].join(','))
      should contain_neutron_plugin_opencontrail('APISERVER/timeout').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_opencontrail('APISERVER/connection_timeout').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples 'neutron::plugins::opencontrail on Debian' do
    let :params do
      {
        :contrail_extensions => ['ipam:ipam','policy:policy','route-table']
      }
    end

    it 'configures /etc/default/neutron-server' do
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
        :path    => '/etc/default/neutron-server',
        :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/opencontrail/ContrailPlugin.ini',
        :tag     => 'neutron-file-line',
      )
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_requires('Anchor[neutron::config::begin]')
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_notifies('Anchor[neutron::config::end]')
    end
  end

  shared_examples 'neutron::plugins::opencontrail on RedHat' do
    let :params do
      {
        :contrail_extensions => ['ipam:ipam','policy:policy','route-table']
      }
    end

    it 'should create plugin symbolic link' do
      should contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/opencontrail/ContrailPlugin.ini',
        :require => 'Package[neutron-plugin-contrail]'
      )
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::plugins::contrail'
      it_behaves_like "neutron::plugins::opencontrail on #{facts[:os]['family']}"
    end
  end
end
