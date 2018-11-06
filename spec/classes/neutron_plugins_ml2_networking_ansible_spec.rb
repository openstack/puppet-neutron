require 'spec_helper'

describe 'neutron::plugins::ml2::networking_ansible' do
  let :default_params do
    { :package_ensure   => 'present',
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  let :params do
    { :host_configs     => {
        'host1' => { 'ansible_network_os' => 'junos',
                     'ansible_host' => '10.0.0.1',
                     'ansible_user' => 'ansible',
                     'ansible_ssh_pass' => 'password1' },
        'host2' => { 'ansible_network_os' => 'junos',
                     'ansible_host' => '10.0.0.1',
                     'ansible_user' => 'ansible',
                     'ansible_ssh_private_key_file' => '/path/to/key',
                     'mac' => '01:23:45:67:89:AB',
                     'manage_vlans' => false},}
    }
  end

  shared_examples_for 'networking-ansible ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'installs networking-ansible python2-networking-ansible package' do
      is_expected.to contain_package('python2-networking-ansible').with(
        :name   => platform_params[:networking_ansible_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      is_expected.to contain_package('python2-networking-ansible').that_requires('Anchor[neutron::install::begin]')
      is_expected.to contain_package('python2-networking-ansible').that_notifies('Anchor[neutron::install::end]')
    end
    it {
     params[:host_configs].each do |host_config|
       is_expected.to contain_neutron__plugins__ml2__networking_ansible_host(host_config.first)

       is_expected.to contain_neutron_plugin_ml2('ansible:host1/ansible_ssh_pass').with_value('password1')
       is_expected.to contain_neutron_plugin_ml2('ansible:host1/ansible_ssh_private_key_file').with_value(nil)

       is_expected.to contain_neutron_plugin_ml2('ansible:host2/ansible_ssh_private_key_file').with_value('/path/to/key')
       is_expected.to contain_neutron_plugin_ml2('ansible:host2/ansible_ssh_pass').with_value(nil)

       is_expected.to contain_neutron_plugin_ml2('ansible:host1/mac').with_value(nil)
       is_expected.to contain_neutron_plugin_ml2('ansible:host2/mac').with_value('01:23:45:67:89:AB')

       is_expected.to contain_neutron_plugin_ml2('ansible:host1/manage_vlans').with_value(nil)
       is_expected.to contain_neutron_plugin_ml2('ansible:host2/manage_vlans').with_value(false)
     end
    }
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
          { :networking_ansible_package => 'python2-networking-ansible'}
        end
      end
      case facts[:osfamily]
      when 'RedHat'
        it_behaves_like 'networking-ansible ml2 plugin'
      when facts[:osfamily] != 'RedHat'
        it 'fails with unsupported osfamily' do
          is_expected.to raise_error(Puppet::Error, /Unsupported osfamily.*/)
        end
      end
    end
  end

end
