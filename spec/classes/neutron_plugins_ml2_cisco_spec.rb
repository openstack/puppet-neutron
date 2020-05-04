require 'spec_helper'

describe 'neutron::plugins::ml2::cisco' do
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
      :package_ensure => 'present'
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron plugin cisco ml2' do
    before do
      params.merge!(default_params)
    end

    it { should contain_class('neutron::params') }

    it 'should have' do
      should contain_package('python-networking-cisco').with(
        :ensure => params[:package_ensure],
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

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'neutron plugin cisco ml2'
      end
    end
  end
end
