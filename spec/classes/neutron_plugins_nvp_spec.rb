require 'spec_helper'

describe 'neutron::plugins::nvp' do
  let :pre_condition do
    "class { 'neutron':
      core_plugin     => 'neutron.plugins.nicira.NeutronPlugin.NvpPluginV2'
     }"
  end

  let :default_params do
    {
      :metadata_mode  => 'access_network',
      :package_ensure => 'present',
      :purge_config   => false,
    }
  end

  let :params do
    {
      :default_tz_uuid => '0344130f-1add-4e86-b36e-ad1c44fe40dc',
      :nvp_controllers => %w(10.0.0.1 10.0.0.2),
      :nvp_user => 'admin',
      :nvp_password => 'password'
    }
  end

  let :optional_params do
    {
      :default_l3_gw_service_uuid => '0344130f-1add-4e86-b36e-ad1c44fe40dc'
    }
  end

  shared_examples 'neutron plugin nvp' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'should have' do
      should contain_package('neutron-plugin-nvp').with(
                 :name   => platform_params[:nvp_server_package],
                 :ensure => p[:package_ensure],
                 :tag    => ['neutron-package', 'openstack'],
             )
    end

    it 'should configure neutron.conf' do
      should contain_neutron_config('DEFAULT/core_plugin').with_value('neutron.plugins.nicira.NeutronPlugin.NvpPluginV2')
    end

    it 'should create plugin symbolic link' do
      should contain_file('/etc/neutron/plugin.ini').with(
        :ensure  => 'link',
        :target  => '/etc/neutron/plugins/nicira/nvp.ini',
      )
      should contain_file('/etc/neutron/plugin.ini').that_requires('Anchor[neutron::config::begin]')
      should contain_file('/etc/neutron/plugin.ini').that_notifies('Anchor[neutron::config::end]')
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_plugin_nvp').with({
        :purge => false
      })
    end

    it 'should configure nvp.ini' do
      should contain_neutron_plugin_nvp('DEFAULT/default_tz_uuid').with_value(p[:default_tz_uuid])
      should contain_neutron_plugin_nvp('nvp/metadata_mode').with_value(p[:metadata_mode])
      should contain_neutron_plugin_nvp('DEFAULT/nvp_controllers').with_value(p[:nvp_controllers].join(','))
      should contain_neutron_plugin_nvp('DEFAULT/nvp_user').with_value(p[:nvp_user])
      should contain_neutron_plugin_nvp('DEFAULT/nvp_password').with_value(p[:nvp_password])
      should contain_neutron_plugin_nvp('DEFAULT/nvp_password').with_secret( true )
      should_not contain_neutron_plugin_nvp('DEFAULT/default_l3_gw_service_uuid').with_value(p[:default_l3_gw_service_uuid])
    end

    context 'configure nvp with optional params' do
      before :each do
        params.merge!(optional_params)
      end

      it 'should configure nvp.ini' do
        should contain_neutron_plugin_nvp('DEFAULT/default_l3_gw_service_uuid').with_value(params[:default_l3_gw_service_uuid])
      end
    end

    context 'configure nvp with wrong core_plugin configure' do
      let :pre_condition do
        "class { 'neutron':
          core_plugin     => 'foo' }"
      end

      it { should raise_error(Puppet::Error, /nvp plugin should be the core_plugin in neutron.conf/) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :nvp_server_package => 'neutron-plugin-nicira'
          }
        when 'RedHat'
          {
            :nvp_server_package => 'openstack-neutron-nicira'
          }
        end
      end

      it_behaves_like 'neutron plugin nvp'
    end
  end
end
