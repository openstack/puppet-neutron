require 'spec_helper'

describe 'neutron::plugins::ml2::opendaylight' do
  let :pre_condition do
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2'
     }"
  end

  let :default_params do
    {
      :package_ensure          => 'present',
      :odl_url                 => '<SERVICE DEFAULT>',
      :ovsdb_connection        => 'tcp:127.0.0.1:6639',
      :port_binding_controller => '<SERVICE DEFAULT>',
      :odl_hostconf_uri        => '<SERVICE DEFAULT>',
      :odl_features            => '<SERVICE DEFAULT>',
    }
  end

  let :params do
    {
      :odl_username => 'user',
      :odl_password => 'password',
    }
  end

  shared_examples 'neutron plugin opendaylight ml2' do
    before do
      params.merge!(default_params)
    end

    it 'should have' do
      should contain_package('python-networking-odl').with(
        :ensure => params[:package_ensure],
        :tag    => ['openstack', 'neutron-plugin-ml2-package']
        )
    end

    it 'configures ml2_odl settings' do
      should contain_neutron_plugin_ml2('ml2_odl/password').with_value(params[:odl_password]).with_secret(true)
      should contain_neutron_plugin_ml2('ml2_odl/username').with_value(params[:odl_username])
      should contain_neutron_plugin_ml2('ml2_odl/url').with_value(params[:odl_url])
      should contain_neutron_plugin_ml2('ml2_odl/port_binding_controller').with_value(params[:port_binding_controller])
      should contain_neutron_plugin_ml2('ml2_odl/odl_hostconf_uri').with_value(params[:odl_hostconf_uri])
      should contain_neutron_plugin_ml2('ml2_odl/odl_features').with_value(params[:odl_features])
    end

    it 'configures neutron server settings' do
      should contain_neutron_config('OVS/ovsdb_connection').with_value(params[:ovsdb_connection])
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin opendaylight ml2'
    end
  end
end
