require 'spec_helper'

describe 'neutron::plugins::ml2::nuage' do
  let :pre_condition do
    "class { 'neutron':
       core_plugin     => 'ml2' }
     class { 'neutron::keystone::authtoken':
       password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron::plugins::ml2':
       mechanism_drivers => ['nuage'] }"
  end

  let :params do
    {
        :nuage_vsd_ip               => %w(192.168.33.3),
        :nuage_vsd_username         => 'test',
        :nuage_vsd_password         => 'test',
        :nuage_vsd_organization     => 'vsd',
        :nuage_net_partition_name   => 'test',
        :nuage_base_uri_version     => 'v3.0',
        :nuage_cms_id               => '7488fae2-7e51-11e5-8bcf-feff819cdc9f',
        :purge_config               => false,
        :nuage_default_allow_non_ip => false,}
  end

  shared_examples 'neutron plugin ml2 nuage' do

    it { should contain_class('neutron::params') }

    it 'configures neutron.conf' do
      should contain_neutron_config('DEFAULT/core_plugin').with_value('ml2')
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_plugin_nuage').with({
        :purge => false
      })
    end

    it 'should have a nuage plugin ini file' do
      should contain_file('/etc/neutron/plugins/nuage/plugin.ini').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'neutron',
        :mode   => '0640'
      )
    end

    it 'should configure plugin.ini' do
      should contain_neutron_plugin_nuage('RESTPROXY/default_net_partition_name').with_value(params[:nuage_net_partition_name])
      should contain_neutron_plugin_nuage('RESTPROXY/server').with_value(params[:nuage_vsd_ip])
      should contain_neutron_plugin_nuage('RESTPROXY/serverauth')\
        .with_value("#{params[:nuage_vsd_username]}:#{params[:nuage_vsd_password]}")\
        .with_secret(true)
      should contain_neutron_plugin_nuage('RESTPROXY/organization').with_value(params[:nuage_vsd_organization])
      should contain_neutron_plugin_nuage('RESTPROXY/cms_id').with_value(params[:nuage_cms_id])
      should contain_neutron_plugin_nuage('PLUGIN/default_allow_non_ip').with_value(params[:nuage_default_allow_non_ip])
    end

    context 'when allowing Non-IP' do
      before :each do
        params.merge!(:nuage_default_allow_non_ip => true)
      end
      it 'default_allow_non_ip is set to true' do
        should contain_neutron_plugin_nuage('PLUGIN/default_allow_non_ip').with_value(true)
      end
    end
  end

  shared_examples 'neutron plugin ml2 nuage on Debian' do
    it 'configures /etc/default/neutron-server' do
      should contain_file_line('neutron-server-DAEMON_ARGS').with(
        :path => '/etc/default/neutron-server',
        :line => 'DAEMON_ARGS="$DAEMON_ARGS --config-file /etc/neutron/plugins/nuage/plugin.ini"',
        :tag  => 'neutron-file-line',
      )
      should contain_file_line('neutron-server-DAEMON_ARGS').that_requires('Anchor[neutron::config::begin]')
      should contain_file_line('neutron-server-DAEMON_ARGS').that_notifies('Anchor[neutron::config::end]')
    end
  end

  shared_examples 'neutron plugin ml2 nuage on RedHat' do
    it 'should create plugin symbolic link' do
      should contain_file('/etc/neutron/conf.d/neutron-server/nuage_plugin.conf').with(
        :ensure => 'link',
        :target => '/etc/neutron/plugins/nuage/plugin.ini',
        :tag    => 'neutron-config-file'
      )
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin ml2 nuage'
      it_behaves_like "neutron plugin ml2 nuage on #{facts[:os]['family']}"
    end
  end
end
