require 'spec_helper'

describe 'neutron::plugins::plumgrid' do
  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron': }"
  end

  let :default_params do
  {
    :director_server      => '127.0.0.1',
    :director_server_port => '443',
    :servertimeout        => '99',
    :connection           => 'http://127.0.0.1:5000/v3',
    :controller_priv_host => '127.0.0.1',
    :auth_protocol        => 'http',
    :identity_version     => 'v3',
    :user_domain_name     => 'Default',
    :nova_metadata_ip     => '127.0.0.1',
    :nova_metadata_host   => '127.0.0.1',
    :nova_metadata_port   => '8775',
    :nova_metadata_subnet => '127.0.0.1/24',
    :connector_type       => 'distributed',
    :purge_config         => false,
  }
  end

  shared_examples 'neutron plumgrid plugin' do
    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'installs plumgrid plugin package' do
      should contain_package('neutron-plugin-plumgrid').with(
        :ensure => 'present'
      )
    end

    it 'installs plumgrid plumlib package' do
      should contain_package('neutron-plumlib-plumgrid').with(
        :ensure => 'present'
      )
    end

    it 'passes purge to resource plugin_plumgrid' do
      should contain_resources('neutron_plugin_plumgrid').with({
        :purge => false
      })
    end

    it 'passes purge to resource plumlib_plumgrid' do
      should contain_resources('neutron_plumlib_plumgrid').with({
        :purge => false
      })
    end

    it 'should perform default configuration of plumgrid plugin' do
      should contain_neutron_plugin_plumgrid('PLUMgridDirector/director_server').with_value(params[:director_server])
      should contain_neutron_plugin_plumgrid('PLUMgridDirector/director_server_port').with_value(params[:director_server_port])
      should contain_neutron_plugin_plumgrid('PLUMgridDirector/username').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_plumgrid('PLUMgridDirector/password').with_value('<SERVICE DEFAULT>').with_secret(true)
      should contain_neutron_plugin_plumgrid('PLUMgridDirector/servertimeout').with_value(params[:servertimeout])
      should contain_neutron_plugin_plumgrid('database/connection').with_value(params[:connection])
      should contain_neutron_plugin_plumgrid('l2gateway/vendor').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_plumgrid('l2gateway/sw_username').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_plumgrid('l2gateway/sw_password').with_value('<SERVICE DEFAULT>').with_secret(true)
    end

    it 'should perform default configuration of plumgrid plumlib' do
      auth_uri = params[:auth_protocol] + "://" + params[:controller_priv_host] + ":" + "5000/" + params[:identity_version];
      should contain_neutron_plumlib_plumgrid('keystone_authtoken/auth_uri').with_value(auth_uri)
      should contain_neutron_plumlib_plumgrid('keystone_authtoken/www_authenticate_uri').with_value(auth_uri)
      should contain_neutron_plumlib_plumgrid('keystone_authtoken/identity_version').with_value(params[:identity_version])
      should contain_neutron_plumlib_plumgrid('keystone_authtoken/user_domain_name').with_value(params[:user_domain_name])
      should contain_neutron_plumlib_plumgrid('PLUMgridMetadata/enable_pg_metadata').with_value('True')
      should contain_neutron_plumlib_plumgrid('PLUMgridMetadata/metadata_mode').with_value('local')
      should contain_neutron_plumlib_plumgrid('PLUMgridMetadata/nova_metadata_ip').with_value(params[:nova_metadata_ip])
      should contain_neutron_plumlib_plumgrid('PLUMgridMetadata/nova_metadata_host').with_value(params[:nova_metadata_host])
      should contain_neutron_plumlib_plumgrid('PLUMgridMetadata/nova_metadata_port').with_value(params[:nova_metadata_port])
      should contain_neutron_plumlib_plumgrid('PLUMgridMetadata/nova_metadata_subnet').with_value(params[:nova_metadata_subnet])
      should contain_neutron_plumlib_plumgrid('PLUMgridMetadata/metadata_proxy_shared_secret').with_value('<SERVICE DEFAULT>').with_secret(true)
      should contain_neutron_plumlib_plumgrid('ConnectorType/connector_type').with_value('distributed')
    end

  end

  shared_examples 'neutron::plugins::plumgrid on Debian' do
    it 'configures /etc/default/neutron-server' do
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').with(
        :path    => '/etc/default/neutron-server',
        :match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
        :line    => 'NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/plumgrid/plumgrid.ini',
        :tag     => 'neutron-file-line',
      )
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_requires('Anchor[neutron::config::begin]')
      should contain_file_line('/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG').that_notifies('Anchor[neutron::config::end]')
    end
  end

  shared_examples 'neutron::plugins::plumgrid on RedHat' do
    it 'should create plugin symbolic link' do
      should contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/plumgrid/plumgrid.ini',
        :tag     => 'neutron-config-file')
      should contain_file('/etc/neutron/plugin.ini').that_requires('Anchor[neutron::config::begin]')
      should contain_file('/etc/neutron/plugin.ini').that_notifies('Anchor[neutron::config::end]')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plumgrid plugin'
      it_behaves_like "neutron::plugins::plumgrid on #{facts[:osfamily]}"
    end
  end
end
