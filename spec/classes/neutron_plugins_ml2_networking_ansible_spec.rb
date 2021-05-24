require 'spec_helper'

describe 'neutron::plugins::ml2::networking_ansible' do
  let :default_params do
    {
      :package_ensure   => 'present',
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
                     'manage_vlans' => false},},
      :coordination_uri => 'etcd://127.0.0.1:2379'
    }
  end

  shared_examples 'networking-ansible ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'installs networking-ansible python-networking-ansible package' do
      should contain_package('python-networking-ansible').with(
        :name   => platform_params[:networking_ansible_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-plugin-ml2-package'],
      )
      should contain_package('python-networking-ansible').that_requires('Anchor[neutron::install::begin]')
      should contain_package('python-networking-ansible').that_notifies('Anchor[neutron::config::end]')
    end

    it 'should configure non-host config' do
      should contain_neutron_plugin_ml2('ml2_ansible/coordination_uri').with_value('etcd://127.0.0.1:2379')
    end

    it {
     params[:host_configs].each do |host_config|
       should contain_neutron__plugins__ml2__networking_ansible_host(host_config.first)

       should contain_neutron_plugin_ml2('ansible:host1/ansible_ssh_pass').with_value('password1')
       should contain_neutron_plugin_ml2('ansible:host1/ansible_ssh_private_key_file').with_value(nil)

       should contain_neutron_plugin_ml2('ansible:host2/ansible_ssh_private_key_file').with_value('/path/to/key')
       should contain_neutron_plugin_ml2('ansible:host2/ansible_ssh_pass').with_value(nil)

       should contain_neutron_plugin_ml2('ansible:host1/mac').with_value(nil)
       should contain_neutron_plugin_ml2('ansible:host2/mac').with_value('01:23:45:67:89:AB')

       should contain_neutron_plugin_ml2('ansible:host1/manage_vlans').with_value(nil)
       should contain_neutron_plugin_ml2('ansible:host2/manage_vlans').with_value(false)
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
          if facts[:operatingsystem] == 'Fedora'
            { :networking_ansible_package => 'python3-networking-ansible'}
          else
            if facts[:operatingsystemmajrelease] > '7'
              { :networking_ansible_package => 'python3-networking-ansible'}
            else
              { :networking_ansible_package => 'python-networking-ansible'}
            end
          end
        end
      end
      case facts[:osfamily]
      when 'RedHat'
        it_behaves_like 'networking-ansible ml2 plugin'
      when facts[:osfamily] != 'RedHat'
        it 'fails with unsupported osfamily' do
          should raise_error(Puppet::Error, /Unsupported osfamily.*/)
        end
      end
    end
  end
end
