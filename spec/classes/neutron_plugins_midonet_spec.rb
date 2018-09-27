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
    :midonet_cluster_ip    => '127.0.0.1',
    :midonet_cluster_port  => '8181',
    :keystone_username     => 'neutron',
    :keystone_password     => 'test_midonet',
    :keystone_tenant       => 'services',
    :purge_config          => false,
  }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron midonet plugin' do

    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'should install package python-networking-midonet' do
      is_expected.to contain_package('python-networking-midonet').with(
        :ensure  => 'present')
    end

    it 'should create plugin symbolic link' do
      is_expected.to contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/midonet/midonet.ini')
      is_expected.to contain_file('/etc/neutron/plugin.ini').that_requires('Anchor[neutron::config::begin]')
      is_expected.to contain_file('/etc/neutron/plugin.ini').that_notifies('Anchor[neutron::config::end]')
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_plugin_midonet').with({
        :purge => false
      })
    end

    it 'should perform default configuration of' do
      midonet_uri = "http://" + params[:midonet_cluster_ip] + ":" + params[:midonet_cluster_port] + "/midonet-api";
      is_expected.to contain_neutron_plugin_midonet('MIDONET/midonet_uri').with_value(midonet_uri)
      is_expected.to contain_neutron_plugin_midonet('MIDONET/username').with_value(params[:keystone_username])
      is_expected.to contain_neutron_plugin_midonet('MIDONET/password').with_value(params[:keystone_password])
      is_expected.to contain_neutron_plugin_midonet('MIDONET/project_id').with_value(params[:keystone_tenant])
    end

  end

  shared_examples_for 'neutron midonet plugin using deprecated params' do
    let :params do
      {
        :midonet_api_ip    => '192.168.0.1',
        :midonet_api_port  => '8181',
      }
    end
    before do
      params.merge!(default_params)
    end
    it 'should take into account deprecated parameters first' do
      midonet_uri = "http://" + params[:midonet_api_ip] + ":" + params[:midonet_api_port] + "/midonet-api";
      is_expected.to contain_neutron_plugin_midonet('MIDONET/midonet_uri').with_value(midonet_uri)
    end
    it 'should take into account deprecated parameters first' do
      bad_midonet_uri = "http://" + params[:midonet_cluster_ip] + ":" + params[:midonet_cluster_port] + "/midonet-api";
      is_expected.to_not contain_neutron_plugin_midonet('MIDONET/midonet_uri').with_value(bad_midonet_uri)
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian',
         :os       => { :name  => 'Debian', :family => 'Debian', :release => { :major => '8', :minor => '0' } },
      }))
    end
    it 'configures /etc/default/neutron-server' do
      is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
        :path    => '/etc/default/neutron-server',
        :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/midonet/midonet.ini',
      )
      is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_requires('Anchor[neutron::config::begin]')
      is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_notifies('Anchor[neutron::config::end]')
    end
    it_configures 'neutron midonet plugin'
    it_configures 'neutron midonet plugin using deprecated params'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7',
         :os       => { :name  => 'CentOS', :family => 'RedHat', :release => { :major => '7', :minor => '0' } },
      }))
    end
    it_configures 'neutron midonet plugin'
    it_configures 'neutron midonet plugin using deprecated params'
  end

end
