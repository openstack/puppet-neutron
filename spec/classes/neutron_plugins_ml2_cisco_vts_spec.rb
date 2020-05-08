require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::vts' do
  let :pre_condition do
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin => 'ml2'
     }"
  end

  let :default_params do
    {
      :vts_timeout      => '<SERVICE DEFAULT>',
      :vts_sync_timeout => '<SERVICE DEFAULT>',
      :vts_retry_count  => '<SERVICE DEFAULT>',
      :package_ensure   => 'present',
    }
  end

  let :params do
    {
      :vts_username => 'user',
      :vts_password => 'password',
      :vts_url      => 'http://abc123',
      :vts_vmmid    => '12345',
    }
  end

  shared_examples 'neutron plugin ml2 cisco vts' do
    before do
      params.merge!(default_params)
    end

    it 'should have' do
      should contain_package('python-cisco-controller').with(
          :ensure => params[:package_ensure],
          :tag    => ['openstack', 'neutron-plugin-ml2-package']
      )
    end

    it 'configures ml2_cc cisco_vts settings' do
      should contain_neutron_plugin_ml2('ml2_cc/password').with_value(params[:vts_password]).with_secret(true)
      should contain_neutron_plugin_ml2('ml2_cc/username').with_value(params[:vts_username])
      should contain_neutron_plugin_ml2('ml2_cc/url').with_value(params[:vts_url])
      should contain_neutron_plugin_ml2('ml2_cc/timeout').with_value(params[:vts_timeout])
      should contain_neutron_plugin_ml2('ml2_cc/sync_timeout').with_value(params[:vts_sync_timeout])
      should contain_neutron_plugin_ml2('ml2_cc/retry_count').with_value(params[:vts_retry_count])
      should contain_neutron_plugin_ml2('ml2_cc/vmm_id').with_value(params[:vts_vmmid])
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin ml2 cisco vts'
    end
  end
end
