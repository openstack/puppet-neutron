require 'spec_helper'

describe 'neutron::agents::taas' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {}
  end

  shared_examples 'neutron::agents::taas' do
    context 'with defaults' do
      it { should contain_class('neutron::params') }

      it 'configures ml2_plugin.conf' do
        should contain_neutron_plugin_ml2('DEFAULT/taas_agent_periodic_interval').with_value('<SERVICE DEFAULT>')
      end

      it 'installs neutron taas package' do
        should contain_package('neutron-taas').with(
          :ensure => 'installed',
          :name   => platform_params[:taas_package],
          :tag    => ['openstack', 'neutron-package'],
        )
      end
    end

    context 'with parameters' do
      let :params do
        {
          :taas_agent_periodic_interval => 5,
        }
      end

      it 'configures ml2_plugin.conf' do
        should contain_neutron_plugin_ml2('DEFAULT/taas_agent_periodic_interval').with_value(5)
      end
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
        case facts[:os]['family']
        when 'Debian'
          {
            :taas_package => 'python3-neutron-taas'
          }
        when 'RedHat'
          {
            :taas_package => 'python3-tap-as-a-service'
          }
        end
      end

      it_behaves_like 'neutron::agents::taas'
    end
  end
end
