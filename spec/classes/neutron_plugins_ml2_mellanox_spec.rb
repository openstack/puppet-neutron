require 'spec_helper'

describe 'neutron::plugins::ml2::mellanox' do
  let :pre_condition do
    "class { 'neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin'
     }"
  end

  let :params do
    {}
  end

  shared_examples 'neutron plugin mellanox ml2' do
    it { should contain_class('neutron::params') }

    it 'should have' do
      should contain_package(platform_params[:mlnx_plugin_package]).with(
        :ensure => 'installed',
        :tag    => ['openstack', 'neutron-plugin-ml2-package']
        )
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
            :mlnx_plugin_package => 'python3-networking-mlnx',
          }
        when 'RedHat'
          {
            :mlnx_plugin_package => 'python3-networking-mlnx',
          }
        end
      end

      it_behaves_like 'neutron plugin mellanox ml2'
    end
  end
end
