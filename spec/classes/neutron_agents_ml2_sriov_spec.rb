require 'spec_helper'

describe 'neutron::agents::ml2::sriov' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
    { :package_ensure             => 'present',
      :enabled                    => true,
      :manage_service             => true,
      :polling_interval           => 2,
      :supported_pci_vendor_devs  => [],
      :purge_config               => false,
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

  shared_examples_for 'neutron sriov-nic agent with ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_sriov_agent_config').with({
        :purge => false
      })
    end

    it 'configures /etc/neutron/plugins/ml2/sriov_agent.ini' do
      is_expected.to contain_neutron_sriov_agent_config('sriov_nic/polling_interval').with_value(p[:polling_interval])
      is_expected.to contain_neutron_sriov_agent_config('sriov_nic/exclude_devices').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_sriov_agent_config('sriov_nic/physical_device_mappings').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_sriov_agent_config('agent/extensions').with_value(['<SERVICE DEFAULT>'])
      is_expected.to contain_neutron_sriov_agent_config('securitygroup/firewall_driver').with_value('neutron.agent.firewall.NoopFirewallDriver')
    end

    it 'does not configure numvfs by default' do
      is_expected.not_to contain_neutron_agents_ml2_sriov_numvfs('<SERVICE DEFAULT>')
    end

    it 'installs neutron sriov-nic agent package' do
      is_expected.to contain_package('neutron-sriov-nic-agent').with(
        :name   => platform_params[:sriov_nic_agent_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      is_expected.to contain_package('neutron-sriov-nic-agent').that_requires('Anchor[neutron::install::begin]')
      is_expected.to contain_package('neutron-sriov-nic-agent').that_notifies('Anchor[neutron::install::end]')
    end

    it 'configures neutron sriov agent service' do
      is_expected.to contain_service('neutron-sriov-nic-agent-service').with(
        :name    => platform_params[:sriov_nic_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      is_expected.to contain_service('neutron-sriov-nic-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('neutron-sriov-nic-agent-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'when number_of_vfs is empty' do
      before :each do
        params.merge!(:number_of_vfs => "")
      end

      it 'does not configure numvfs ' do
        is_expected.not_to contain_neutron_agents_ml2_sriov_numvfs('<SERVICE DEFAULT>')
      end
    end

    context 'when number_of_vfs is configured' do
      before :each do
        params.merge!(:number_of_vfs => ['eth0:4','eth1:5'])
      end

      it 'configures numvfs' do
        is_expected.to contain_neutron_agent_sriov_numvfs('eth0:4').with( :ensure => 'present' )
        is_expected.to contain_neutron_agent_sriov_numvfs('eth1:5').with( :ensure => 'present')
      end
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        is_expected.to contain_service('neutron-sriov-nic-agent-service').without_ensure
      end
    end

    context 'when supplying device mapping' do
      before :each do
        params.merge!(:physical_device_mappings => ['physnet1:eth1'],
                      :exclude_devices          => ['physnet1:eth2'])
      end

      it 'configures physical device mappings with exclusion' do
        is_expected.to contain_neutron_sriov_agent_config('sriov_nic/exclude_devices').with_value(['physnet1:eth2'])
        is_expected.to contain_neutron_sriov_agent_config('sriov_nic/physical_device_mappings').with_value(['physnet1:eth1'])
      end
    end

    context 'when supplying empty device mapping' do
      before :each do
        params.merge!(:physical_device_mappings => "",
                      :exclude_devices          => "")
      end

      it 'configures physical device mappings with exclusion' do
        is_expected.to contain_neutron_sriov_agent_config('sriov_nic/exclude_devices').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_sriov_agent_config('sriov_nic/physical_device_mappings').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when supplying extensions for ML2 SR-IOV agent' do
      before :each do
        params.merge!(:extensions => ['qos'])
      end

      it 'configures extensions' do
        is_expected.to contain_neutron_sriov_agent_config('agent/extensions').with_value(params[:extensions].join(','))
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian'
      }))
    end

    let :platform_params do
      { :sriov_nic_agent_package => 'neutron-sriov-agent',
        :sriov_nic_agent_service => 'neutron-sriov-agent' }
    end

    it_configures 'neutron sriov-nic agent with ml2 plugin'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :platform_params do
      { :sriov_nic_agent_package => 'openstack-neutron-sriov-nic-agent',
        :sriov_nic_agent_service => 'neutron-sriov-nic-agent' }
    end

    it_configures 'neutron sriov-nic agent with ml2 plugin'
  end
end
