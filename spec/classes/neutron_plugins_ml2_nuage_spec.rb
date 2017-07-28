require 'spec_helper'

describe 'neutron::plugins::ml2::nuage' do

  let :pre_condition do
    "class { '::neutron':
       rabbit_password => 'passw0rd',
       core_plugin     => 'ml2' }
     class { '::neutron::keystone::authtoken':
       password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { '::neutron::plugins::ml2':
       mechanism_drivers => ['nuage'] }"
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
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
        :purge_config             => false,}
  end

  shared_examples_for 'neutron plugin ml2 nuage' do

    it { is_expected.to contain_class('neutron::params') }

    it 'configures neutron.conf' do
      is_expected.to contain_neutron_config('DEFAULT/core_plugin').with_value('ml2')
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_plugin_nuage').with({
        :purge => false
      })
    end

    it 'should have a nuage plugin ini file' do
      is_expected.to contain_file('/etc/neutron/plugins/nuage/plugin.ini').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'neutron',
        :mode   => '0640'
      )
    end

    it 'should configure plugin.ini' do
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/default_net_partition_name').with_value(params[:nuage_net_partition_name])
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/server').with_value(params[:nuage_vsd_ip])
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/organization').with_value(params[:nuage_vsd_organization])
      is_expected.to contain_neutron_plugin_nuage('RESTPROXY/cms_id').with_value(params[:nuage_cms_id])
    end

    context 'configure ml2 nuage with wrong core_plugin configuration' do
      let :pre_condition do
        "class { 'neutron':
          rabbit_password => 'passw0rd',
          core_plugin     => 'foo' }"
      end

      it_raises 'a Puppet::Error', /Nuage should be the mechanism driver in neutron.conf/
    end

    it 'should have a nuage plugin conf file' do
      is_expected.to contain_file(platform_params[:nuage_conf_file]).with(
        :ensure => platform_params[:nuage_file_ensure],
        :target => platform_params[:nuage_file_target]
      )
    end

    context 'configure ml2 nuage with wrong mechanism_driver configuration' do
      let :pre_condition do
        "class { '::neutron::plugins::ml2':
          mechanism_drivers => ['bar'] }"
      end

      it_raises 'a Puppet::Error', /Nuage should be the mechanism driver in neutron.conf/
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'RedHat'
          { :nuage_conf_file   => '/etc/neutron/conf.d/neutron-server/nuage_plugin.conf',
            :nuage_file_ensure => 'link',
            :nuage_file_target => '/etc/neutron/plugins/nuage/plugin.ini'
          }
        when 'Debian'
          { :nuage_conf_file   => '/etc/default/neutron-server',
            :nuage_file_ensure => 'present',
            :nuage_file_target => nil
          }
        end
      end

      it_configures 'neutron plugin ml2 nuage'
    end
  end
end
