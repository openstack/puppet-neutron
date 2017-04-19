require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::vts' do

  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'ml2' }"
  end

  let :default_params do
    {
      :vts_username            => '<SERVICE DEFAULT>',
      :vts_password            => '<SERVICE DEFAULT>',
      :vts_url                 => '<SERVICE DEFAULT>',
      :vts_timeout             => '<SERVICE DEFAULT>',
      :vts_sync_timeout        => '<SERVICE DEFAULT>',
      :vts_retry_count         => '<SERVICE DEFAULT>'
    }
  end

  let :params do
    {}
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
      :concat_basedir         => '/',
    }
  end


  shared_examples_for 'neutron plugin cisco vts ml2' do
    before do
      params.merge!(default_params)
    end

    it 'configures ml2_cisco_vts settings' do
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/password').with_value(params[:vts_password]).with_secret(true)
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/username').with_value(params[:vts_username])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/url').with_value(params[:vts_url])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/timeout').with_value(params[:vts_timeout])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/sync_timeout').with_value(params[:vts_sync_timeout])
      is_expected.to contain_neutron_plugin_ml2('ml2_cc/retry_count').with_value(params[:vts_retry_count])
    end
  end

  begin
    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily               => 'RedHat',
           :operatingsystemrelease => '7'
        }))
      end

      it_configures 'neutron plugin cisco vts ml2'
    end
  end
end
