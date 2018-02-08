require 'spec_helper'

describe 'neutron::plugins::ml2::networking_baremetal' do
  let :default_params do
    { :package_ensure             => 'present',
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  let :params do
    {}
  end

  shared_examples_for 'networking-baremetal ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'installs networking-baremetal python2-networking-baremetal package' do
      is_expected.to contain_package('python2-networking-baremetal').with(
        :name   => platform_params[:networking_baremetal_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      is_expected.to contain_package('python2-networking-baremetal').that_requires('Anchor[neutron::install::begin]')
      is_expected.to contain_package('python2-networking-baremetal').that_notifies('Anchor[neutron::install::end]')
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
        when 'RedHat'
          { :networking_baremetal_package => 'python2-networking-baremetal'}
        end
      end
      case facts[:osfamily]
      when 'RedHat'
        it_behaves_like 'networking-baremetal ml2 plugin'
      when facts[:osfamily] != 'RedHat'
        it 'fails with unsupported osfamily' do
          is_expected.to raise_error(Puppet::Error, /Unsupported osfamily.*/)
        end
      end
    end
  end

end
