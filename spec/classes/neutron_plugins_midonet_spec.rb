require 'spec_helper'

describe 'neutron::plugins::midonet' do

  let :pre_condition do
    "class { 'neutron::server': auth_password => 'password' }
     class { 'neutron': rabbit_password => 'passw0rd' }
     package { 'python-neutron-plugin-midonet': }"
  end

  let :default_params do
  {
    :midonet_api_ip    => '127.0.0.1',
    :midonet_api_port  => '8080',
    :keystone_username => 'neutron',
    :keystone_password => 'test_midonet',
    :keystone_tenant   => 'services'
  }
  end

  shared_examples_for 'neutron midonet plugin' do

    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'should create plugin symbolic link' do
      should contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/midonet/midonet.ini',
        :require => 'Package[python-neutron-plugin-midonet]')
    end

    it 'should perform default configuration of' do
      midonet_uri = "http://" + params[:midonet_api_ip] + ":" + params[:midonet_api_port] + "/midonet-api";
      should contain_neutron_plugin_midonet('MIDONET/midonet_uri').with_value(midonet_uri)
      should contain_neutron_plugin_midonet('MIDONET/username').with_value(params[:keystone_username])
      should contain_neutron_plugin_midonet('MIDONET/password').with_value(params[:keystone_password])
      should contain_neutron_plugin_midonet('MIDONET/project_id').with_value(params[:keystone_tenant])
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian'}
    end
    it 'configures /etc/default/neutron-server' do
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
        :path    => '/etc/default/neutron-server',
        :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/midonet/midonet.ini',
        :require => ['Package[neutron-server]', 'Package[python-neutron-plugin-midonet]'],
        :notify  => 'Service[neutron-server]'
      )
    end
    it_configures 'neutron midonet plugin'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat'}
    end
    it_configures 'neutron midonet plugin'
  end

end
