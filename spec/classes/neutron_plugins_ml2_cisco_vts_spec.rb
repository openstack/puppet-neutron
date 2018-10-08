require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::vts' do

  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2' }"
  end

  let :default_params do
    {
      :vts_timeout             => '<SERVICE DEFAULT>',
      :vts_sync_timeout        => '<SERVICE DEFAULT>',
      :vts_retry_count         => '<SERVICE DEFAULT>',
      :package_ensure          => 'present',
    }
  end

  let :params do
    {
     :vts_username            => 'user',
     :vts_password            => 'password',
     :vts_url                 => 'http://abc123',
     :vts_vmmid               => '12345',
    }
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
    }
  end

  shared_examples_for 'neutron plugin ml2 cisco vts' do
    before do
      params.merge!(default_params)
    end

    it 'should have' do
      is_expected.to contain_package('python-cisco-controller').with(
          :ensure => params[:package_ensure],
          :tag    => 'openstack'
      )
    end

    it 'configures ml2_cc cisco_vts settings' do
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/password').with_value(params[:vts_password]).with_secret(true)
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/username').with_value(params[:vts_username])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/url').with_value(params[:vts_url])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/timeout').with_value(params[:vts_timeout])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/sync_timeout').with_value(params[:vts_sync_timeout])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/retry_count').with_value(params[:vts_retry_count])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/vmm_id').with_value(params[:vts_vmmid])

    end
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7',
         :os       => { :name  => 'CentOS', :family => 'RedHat', :release => { :major => '7', :minor => '0' } },
      }))
    end
    it_configures 'neutron plugin ml2 cisco vts'
  end

    context 'on Debian platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
          :osfamily               => 'Debian',
          :os       => { :name  => 'Debian', :family => 'Debian', :release => { :major => '8', :minor => '0' } },
      }))
    end
    it_configures 'neutron plugin ml2 cisco vts'
  end
end
