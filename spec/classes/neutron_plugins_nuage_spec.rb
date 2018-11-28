require 'spec_helper'

describe 'neutron::plugins::nuage' do
  let :pre_condition do
    "class { 'neutron':
      core_plugin     => 'nuage_neutron.plugins.nuage.plugin.NuagePlugin' }
      class { '::neutron::keystone::authtoken':
        password => 'passw0rd',
      }
      class { 'neutron::server': }"
  end

  let :params do
    {
      :nuage_vsd_ip             => %w(192.168.33.3),
      :nuage_vsd_username       => 'test',
      :nuage_vsd_password       => 'test',
      :nuage_vsd_organization   => 'vsd',
      :nuage_net_partition_name => 'test',
      :nuage_base_uri_version   => 'v3.0',
      :nuage_cms_id             => '7488fae2-7e51-11e5-8bcf-feff819cdc9f',
      :purge_config             => false,
    }
  end

  shared_examples 'neutron plugin nuage' do
    it { should contain_class('neutron::params') }

    it 'should have a nuage plugin ini file' do
      should contain_file('/etc/neutron/plugins/nuage/plugin.ini').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'neutron',
        :mode   => '0640'
      )
    end

    it 'should configure neutron.conf' do
      should contain_neutron_config('DEFAULT/core_plugin').with_value('nuage_neutron.plugins.nuage.plugin.NuagePlugin')
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_plugin_nuage').with({
        :purge => false
      })
    end

    it 'should configure plugin.ini' do
      should contain_neutron_plugin_nuage('RESTPROXY/default_net_partition_name').with_value(params[:nuage_net_partition_name])
      should contain_neutron_plugin_nuage('RESTPROXY/server').with_value(params[:nuage_vsd_ip])
      should contain_neutron_plugin_nuage('RESTPROXY/organization').with_value(params[:nuage_vsd_organization])
      should contain_neutron_plugin_nuage('RESTPROXY/cms_id').with_value(params[:nuage_cms_id])
    end

    context 'configure nuage with wrong core_plugin configure' do
      let :pre_condition do
        "class { 'neutron':
          core_plugin     => 'foo' }"
      end

      it { should raise_error(Puppet::Error, /Nuage plugin should be the core_plugin in neutron.conf/) }
    end
  end

  shared_examples 'neutron::plugin::nuage on Debian' do
    it 'configures /etc/default/neutron-server' do
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
        :path    => '/etc/default/neutron-server',
        :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/nuage/plugin.ini',
      )
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_requires('Anchor[neutron::config::begin]')
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_notifies('Anchor[neutron::config::end]')
    end
  end

  shared_examples 'neutron::plugin::nuage on RedHat' do
    it 'should create plugin symbolic link' do
      should contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/nuage/plugin.ini')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin nuage'
      it_behaves_like "neutron::plugin::nuage on #{facts[:osfamily]}"
    end
  end
end
