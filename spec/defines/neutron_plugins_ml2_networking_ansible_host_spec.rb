require 'spec_helper'

describe 'neutron::plugins::ml2::networking_ansible_host' do
  let (:title) do
    'myhostname'
  end

  shared_examples 'neutron::plugins::ml2::networking_ansible_host' do
    let :params do
      {
        :ansible_network_os => 'openvswitch',
        :ansible_host       => '192.0.2.10',
        :ansible_user       => 'neutron',
      }
    end

    context 'without credential' do
      it { should raise_error(Puppet::Error) }
    end

    context 'with both ssh pass and ssh key file set' do
      before do
        params.merge!({
          :ansible_ssh_pass             => 'secrete',
          :ansible_ssh_private_key_file => '/var/lib/neutron/.ssh/id_rsa',
        })
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'with ssh pass' do
      before do
        params.merge!({
          :ansible_ssh_pass => 'secrete'
        })
      end

      it 'configures the host' do
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_network_os')\
          .with_value('openvswitch')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_host')\
          .with_value('192.0.2.10')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_user')\
          .with_value('neutron')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_ssh_pass')\
          .with_value('secrete').with_secret(true)
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_ssh_private_key_file')\
          .with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/mac')\
          .with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/manage_vlans')\
          .with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with ssh key file' do
      before do
        params.merge!({
          :ansible_ssh_private_key_file => '/var/lib/neutron/.ssh/id_rsa'
        })
      end

      it 'configures the host' do
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_network_os')\
          .with_value('openvswitch')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_host')\
          .with_value('192.0.2.10')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_user')\
          .with_value('neutron')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_ssh_pass')\
          .with_value('<SERVICE DEFAULT>').with_secret(true)
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_ssh_private_key_file')\
          .with_value('/var/lib/neutron/.ssh/id_rsa')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/mac')\
          .with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/manage_vlans')\
          .with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters' do
      before do
        params.merge!({
          :ansible_ssh_pass => 'secrete',
          :mac              => '00:00:5e:00:53:01',
          :manage_vlans     => false,
        })
      end

      it 'configures the host' do
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_network_os')\
          .with_value('openvswitch')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_host')\
          .with_value('192.0.2.10')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_user')\
          .with_value('neutron')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_ssh_pass')\
          .with_value('secrete').with_secret(true)
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/ansible_ssh_private_key_file')\
          .with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/mac')\
          .with_value('00:00:5e:00:53:01')
        is_expected.to contain_neutron_plugin_ml2('ansible:myhostname/manage_vlans')\
          .with_value(false)
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

      it_behaves_like 'neutron::plugins::ml2::networking_ansible_host'
    end
  end
end
