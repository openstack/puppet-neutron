require 'spec_helper'

describe 'neutron::plugins::ml2::fujitsu' do
  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :package_ensure => 'present'
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron plugin fujitsu ml2' do
    before do
      params.merge!(default_params)
    end

    it { should contain_class('neutron::params') }

    it 'should have' do
      should contain_package('python-networking-fujitsu').with(
        :ensure => params[:package_ensure],
        :tag    => 'openstack'
        )
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron plugin fujitsu ml2'
    end
  end
end
