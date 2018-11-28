require 'spec_helper'

describe 'neutron::plugins::midonet' do
  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron': }"
  end

  let :default_params do
  {
    :midonet_cluster_ip   => '127.0.0.1',
    :midonet_cluster_port => '8181',
    :keystone_username    => 'neutron',
    :keystone_password    => 'test_midonet',
    :keystone_tenant      => 'services',
    :purge_config         => false,
  }
  end

  shared_examples 'neutron midonet plugin' do

    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'should install package python-networking-midonet' do
      should contain_package('python-networking-midonet').with(
        :ensure  => 'present')
    end

    it 'should create plugin symbolic link' do
      should contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/midonet/midonet.ini')
      should contain_file('/etc/neutron/plugin.ini').that_requires('Anchor[neutron::config::begin]')
      should contain_file('/etc/neutron/plugin.ini').that_notifies('Anchor[neutron::config::end]')
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_plugin_midonet').with({
        :purge => false
      })
    end

    it 'should perform default configuration of' do
      midonet_uri = "http://" + params[:midonet_cluster_ip] + ":" + params[:midonet_cluster_port] + "/midonet-api";
      should contain_neutron_plugin_midonet('MIDONET/midonet_uri').with_value(midonet_uri)
      should contain_neutron_plugin_midonet('MIDONET/username').with_value(params[:keystone_username])
      should contain_neutron_plugin_midonet('MIDONET/password').with_value(params[:keystone_password])
      should contain_neutron_plugin_midonet('MIDONET/project_id').with_value(params[:keystone_tenant])
    end

  end

  shared_examples 'neutron midonet plugin using deprecated params' do
    let :params do
      {
        :midonet_api_ip   => '192.168.0.1',
        :midonet_api_port => '8181',
      }
    end

    before do
      params.merge!(default_params)
    end

    it 'should take into account deprecated parameters first' do
      midonet_uri = "http://" + params[:midonet_api_ip] + ":" + params[:midonet_api_port] + "/midonet-api";
      should contain_neutron_plugin_midonet('MIDONET/midonet_uri').with_value(midonet_uri)
    end

    it 'should take into account deprecated parameters first' do
      bad_midonet_uri = "http://" + params[:midonet_cluster_ip] + ":" + params[:midonet_cluster_port] + "/midonet-api";
      should_not contain_neutron_plugin_midonet('MIDONET/midonet_uri').with_value(bad_midonet_uri)
    end
  end

  shared_examples 'neutron midonet plugin on Debian' do
    it 'configures /etc/default/neutron-server' do
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
        :path    => '/etc/default/neutron-server',
        :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/midonet/midonet.ini',
      )
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_requires('Anchor[neutron::config::begin]')
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_notifies('Anchor[neutron::config::end]')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron midonet plugin'
      it_behaves_like 'neutron midonet plugin using deprecated params'

      if facts[:osfamily] == 'Debian'
        it_behaves_like 'neutron midonet plugin on Debian'
      end
    end
  end
end
