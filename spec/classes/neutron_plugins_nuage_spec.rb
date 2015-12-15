require 'spec_helper'

describe 'neutron::plugins::nuage' do

  let :pre_condition do
    "class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.nuage.plugin.NuagePlugin' }
     class { 'neutron::server': auth_password => 'password' }"
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  let :params do
    {
        :nuage_vsd_ip => %w(192.168.33.3),
        :nuage_vsd_username => 'test',
        :nuage_vsd_password => 'test',
        :nuage_vsd_organization => 'vsd',
        :nuage_net_partition_name => 'test',
        :nuage_base_uri_version => 'v3.0',
        :nuage_cms_id => '7488fae2-7e51-11e5-8bcf-feff819cdc9f'}
  end

  shared_examples_for 'neutron plugin nuage' do

    it { is_expected.to contain_class('neutron::params') }

    it 'should have a nuage plugin ini file' do
      is_expected.to contain_file('/etc/neutron/plugins/nuage/plugin.ini').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'neutron',
        :mode   => '0640'
      )
    end

    it 'should configure neutron.conf' do
      is_expected.to contain_neutron_config('DEFAULT/core_plugin').with_value('neutron.plugins.nuage.plugin.NuagePlugin')
    end

    it 'should configure plugin.ini' do
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/default_net_partition_name').with_value(params[:nuage_net_partition_name])
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/server').with_value(params[:nuage_vsd_ip])
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/organization').with_value(params[:nuage_vsd_organization])
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/cms_id').with_value(params[:nuage_cms_id])
    end

    context 'configure nuage with wrong core_plugin configure' do
      let :pre_condition do
        "class { 'neutron':
          rabbit_password => 'passw0rd',
          core_plugin     => 'foo' }"
      end

      it_raises 'a Puppet::Error', /Nuage plugin should be the core_plugin in neutron.conf/
    end
  end
  begin
    context 'on Debian platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily => 'Debian'
        }))
      end

      it_configures 'neutron plugin nuage'
    end

    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily               => 'RedHat',
           :operatingsystemrelease => '7'
        }))
      end

      it_configures 'neutron plugin nuage'
    end
  end
  begin
    context 'on Debian platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily => 'Debian'
        }))
      end

      it 'configures /etc/default/neutron-server' do
        is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
          :path    => '/etc/default/neutron-server',
          :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
          :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/nuage/plugin.ini',
          :notify  => 'Service[neutron-server]'
        )
      end

      it_configures 'neutron plugin nuage'
    end

    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily               => 'RedHat',
           :operatingsystemrelease => '7'
        }))
      end

      it 'should create plugin symbolic link' do
        is_expected.to contain_file('/etc/neutron/plugin.ini').with(
          :ensure  => 'link',
          :target  => '/etc/neutron/plugins/nuage/plugin.ini')
      end

      it_configures 'neutron plugin nuage'
    end
  end

end

