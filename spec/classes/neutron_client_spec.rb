require 'spec_helper'

describe 'neutron::client' do
  shared_examples 'neutron client' do
    it { should contain_class('neutron::deps') }
    it { should contain_class('neutron::params') }

    it 'installs neutron client package' do
      should contain_package('python-neutronclient').with(
        :ensure => 'present',
        :name   => platform_params[:client_package],
        :tag    => ['neutron-support-package', 'openstack']
      )
    end

    it { is_expected.to contain_class('openstacklib::openstackclient') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let :platform_params do
        case facts[:osfamily]
        when 'Debian'
          { :client_package => 'python3-neutronclient' }
        when 'RedHat'
          if facts[:operatingsystem] == 'Fedora'
            { :client_package => 'python3-neutronclient' }
          else
            if facts[:operatingsystemmajrelease] > '7'
              { :client_package => 'python3-neutronclient' }
            else
              { :client_package => 'python-neutronclient' }
            end
          end
        end
      end

      it_behaves_like 'neutron client'
    end
  end
end
