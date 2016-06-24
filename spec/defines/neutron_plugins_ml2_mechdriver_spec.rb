require 'spec_helper'

describe 'neutron::plugins::ml2::mech_driver' do

  let :title do
    'mech_driver'
  end

  let :params do {
    :name => 'sriovnicswitch',
    :supported_pci_vendor_devs => '8086:10ed',
  }
  end

  describe 'provide sriov configuration for Debian' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    it 'configures supported_pci_vendor_devs' do
      is_expected.to contain_neutron_plugin_sriov('ml2_sriov/supported_pci_vendor_devs').with_value('8086:10ed')
    end

    it 'adds ml2_conf_sriov.ini to neutron_server' do
      is_expected.to contain_file_line('DAEMON_ARGS').with(
        :path => '/etc/default/neutron-server',
        :line => 'DAEMON_ARGS="$DAEMON_ARGS --config-file /etc/neutron/plugins/ml2/ml2_conf_sriov.ini"',
      )
    end
  end

  describe 'provide sriov configuration for Redhat' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    it 'configures supported_pci_vendor_devs' do
      is_expected.to contain_neutron_plugin_sriov('ml2_sriov/supported_pci_vendor_devs').with_value('8086:10ed')
    end

    it 'creates symbolic link for ml2_conf_sriov.ini config.d directory' do
      is_expected.to contain_file('/etc/neutron/conf.d/neutron-server/ml2_conf_sriov.conf').with(
        :ensure => 'link',
        :target => '/etc/neutron/plugins/ml2/ml2_conf_sriov.ini'
      )
    end
  end

end

