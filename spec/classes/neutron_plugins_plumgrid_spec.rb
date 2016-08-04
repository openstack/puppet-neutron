require 'spec_helper'

describe 'neutron::plugins::plumgrid' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password' }
     class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
  {
    :director_server      => '127.0.0.1',
    :director_server_port => '443',
    :servertimeout        => '99',
    :connection           => 'http://127.0.0.1:35357/v2.0',
    :controller_priv_host => '127.0.0.1',
    :auth_protocol        => 'http',
    :identity_version     => 'v3',
    :user_domain_name     => 'Default',
    :nova_metadata_ip     => '127.0.0.1',
    :nova_metadata_port   => '8775',
    :nova_metadata_subnet => '127.0.0.1/24',
    :connector_type       => 'distributed',
    :purge_config         => false,
  }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron plumgrid plugin' do

    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'installs plumgrid plugin package' do
      is_expected.to contain_package('neutron-plugin-plumgrid').with(
        :ensure => 'present'
      )
    end

    it 'installs plumgrid plumlib package' do
      is_expected.to contain_package('neutron-plumlib-plumgrid').with(
        :ensure => 'present'
      )
    end

    it 'passes purge to resource plugin_plumgrid' do
      is_expected.to contain_resources('neutron_plugin_plumgrid').with({
        :purge => false
      })
    end

    it 'passes purge to resource plumlib_plumgrid' do
      is_expected.to contain_resources('neutron_plumlib_plumgrid').with({
        :purge => false
      })
    end

    it 'should perform default configuration of plumgrid plugin' do
      is_expected.to contain_neutron_plugin_plumgrid('PLUMgridDirector/director_server').with_value(params[:director_server])
      is_expected.to contain_neutron_plugin_plumgrid('PLUMgridDirector/director_server_port').with_value(params[:director_server_port])
      is_expected.to contain_neutron_plugin_plumgrid('PLUMgridDirector/username').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_plugin_plumgrid('PLUMgridDirector/password').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_plugin_plumgrid('PLUMgridDirector/servertimeout').with_value(params[:servertimeout])
      is_expected.to contain_neutron_plugin_plumgrid('database/connection').with_value(params[:connection])
      is_expected.to contain_neutron_plugin_plumgrid('l2gateway/vendor').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_plugin_plumgrid('l2gateway/sw_username').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_plugin_plumgrid('l2gateway/sw_password').with_value('<SERVICE DEFAULT>')
    end

    it 'should perform default configuration of plumgrid plumlib' do
      is_expected.to contain_neutron_plumlib_plumgrid('keystone_authtoken/admin_user').with_value('admin')
      is_expected.to contain_neutron_plumlib_plumgrid('keystone_authtoken/admin_password').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_plumlib_plumgrid('keystone_authtoken/admin_tenant_name').with_value('admin')
      auth_uri = params[:auth_protocol] + "://" + params[:controller_priv_host] + ":" + "35357/" + params[:identity_version];
      is_expected.to contain_neutron_plumlib_plumgrid('keystone_authtoken/auth_uri').with_value(auth_uri)
      is_expected.to contain_neutron_plumlib_plumgrid('keystone_authtoken/identity_version').with_value(params[:identity_version])
      is_expected.to contain_neutron_plumlib_plumgrid('keystone_authtoken/user_domain_name').with_value(params[:user_domain_name])
      is_expected.to contain_neutron_plumlib_plumgrid('PLUMgridMetadata/enable_pg_metadata').with_value('True')
      is_expected.to contain_neutron_plumlib_plumgrid('PLUMgridMetadata/metadata_mode').with_value('local')
      is_expected.to contain_neutron_plumlib_plumgrid('PLUMgridMetadata/nova_metadata_ip').with_value(params[:nova_metadata_ip])
      is_expected.to contain_neutron_plumlib_plumgrid('PLUMgridMetadata/nova_metadata_port').with_value(params[:nova_metadata_port])
      is_expected.to contain_neutron_plumlib_plumgrid('PLUMgridMetadata/nova_metadata_subnet').with_value(params[:nova_metadata_subnet])
      is_expected.to contain_neutron_plumlib_plumgrid('PLUMgridMetadata/metadata_proxy_shared_secret').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_plumlib_plumgrid('ConnectorType/connector_type').with_value('distributed')
    end

  end

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
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/plumgrid/plumgrid.ini',
        :tag     => 'neutron-file-line',
      )
      is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_requires('Anchor[neutron::config::begin]')
      is_expected.to contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_notifies('Anchor[neutron::config::end]')
    end

    it_configures 'neutron plumgrid plugin'
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
        :target  => '/etc/neutron/plugins/plumgrid/plumgrid.ini',
        :tag     => 'neutron-config-file')
      is_expected.to contain_file('/etc/neutron/plugin.ini').that_requires('Anchor[neutron::config::begin]')
      is_expected.to contain_file('/etc/neutron/plugin.ini').that_notifies('Anchor[neutron::config::end]')
    end

    it_configures 'neutron plumgrid plugin'
  end

end
