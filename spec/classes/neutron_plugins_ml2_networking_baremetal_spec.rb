require 'spec_helper'

describe 'neutron::plugins::ml2::networking_baremetal' do
  let :default_params do
    {
      :package_ensure             => 'present',
    }
  end

  let :params do
    {}
  end

  shared_examples 'networking-baremetal ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'installs networking-baremetal python-networking-baremetal package' do
      should contain_package('python-networking-baremetal').with(
        :name   => platform_params[:networking_baremetal_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-plugin-ml2-package'],
      )
      should contain_package('python-networking-baremetal').that_requires('Anchor[neutron::install::begin]')
      should contain_package('python-networking-baremetal').that_notifies('Anchor[neutron::config::end]')
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
          { :networking_baremetal_package => 'python3-ironic-neutron-agent'}
        when 'RedHat'
          { :networking_baremetal_package => 'python3-networking-baremetal'}
        end
      end

      it_behaves_like 'networking-baremetal ml2 plugin'
    end
  end
end
