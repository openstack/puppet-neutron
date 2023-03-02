require 'spec_helper'

describe 'neutron::agents::ml2::sriov' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :default_params do
    {
      :package_ensure            => 'present',
      :enabled                   => true,
      :polling_interval          => 2,
      :supported_pci_vendor_devs => [],
      :purge_config              => false,
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron sriov-nic agent with ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'passes purge to resource' do
      should contain_resources('neutron_sriov_agent_config').with({
        :purge => false
      })
    end

    it 'configures /etc/neutron/plugins/ml2/sriov_agent.ini' do
      should contain_neutron_sriov_agent_config('sriov_nic/exclude_devices').with_value('<SERVICE DEFAULT>')
      should contain_neutron_sriov_agent_config('sriov_nic/physical_device_mappings').with_value('<SERVICE DEFAULT>')
      should contain_neutron_sriov_agent_config('agent/extensions').with_value(['<SERVICE DEFAULT>'])
      should contain_neutron_sriov_agent_config('agent/polling_interval').with_value(p[:polling_interval])
      should contain_neutron_sriov_agent_config('agent/report_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_sriov_agent_config('DEFAULT/rpc_response_max_timeout').with_value('<SERVICE DEFAULT>')
      should contain_neutron_sriov_agent_config('securitygroup/firewall_driver').with_value('noop')
    end

    it 'does not configure numvfs by default' do
      should_not contain_neutron_agents_ml2_sriov_numvfs('<SERVICE DEFAULT>')
    end

    it 'installs neutron sriov-nic agent package' do
      should contain_package('neutron-sriov-nic-agent').with(
        :name   => platform_params[:sriov_nic_agent_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      should contain_package('neutron-sriov-nic-agent').that_requires('Anchor[neutron::install::begin]')
      should contain_package('neutron-sriov-nic-agent').that_notifies('Anchor[neutron::install::end]')
    end

    it 'configures neutron sriov agent service' do
      should contain_service('neutron-sriov-nic-agent-service').with(
        :name    => platform_params[:sriov_nic_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('neutron-sriov-nic-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-sriov-nic-agent-service').that_notifies('Anchor[neutron::service::end]')
    end

    it 'does not configure resource provider parameters by default' do
      should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_bandwidths').\
        with_value('<SERVICE DEFAULT>')
      should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_hypervisors').\
        with_value('<SERVICE DEFAULT>')
      should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_default_hypervisor').\
        with_value('<SERVICE DEFAULT>')
      should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_inventory_defaults').\
        with_value('<SERVICE DEFAULT>')
    end

    context 'when number_of_vfs is empty' do
      before :each do
        params.merge!(:number_of_vfs => "")
      end

      it 'does not configure numvfs ' do
        should_not contain_neutron_agents_ml2_sriov_numvfs('<SERVICE DEFAULT>')
      end
    end

    context 'when number_of_vfs is configured' do
      before :each do
        params.merge!(:number_of_vfs => ['eth0:4','eth1:5'])
      end

      it 'configures numvfs' do
        should contain_neutron_agent_sriov_numvfs('eth0:4').with( :ensure => 'present' )
        should contain_neutron_agent_sriov_numvfs('eth1:5').with( :ensure => 'present')
      end
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not manage the service' do
        should_not contain_service('neutron-sriov-nic-agent-service')
      end
    end

    context 'when supplying device mapping' do
      before :each do
        params.merge!(:physical_device_mappings => ['physnet1:eth1'],
                      :exclude_devices          => ['physnet1:eth2'])
      end

      it 'configures physical device mappings with exclusion' do
        should contain_neutron_sriov_agent_config('sriov_nic/exclude_devices').with_value(['physnet1:eth2'])
        should contain_neutron_sriov_agent_config('sriov_nic/physical_device_mappings').with_value(['physnet1:eth1'])
      end
    end

    context 'when supplying empty device mapping' do
      before :each do
        params.merge!(:physical_device_mappings => "",
                      :exclude_devices          => "")
      end

      it 'configures physical device mappings with exclusion' do
        should contain_neutron_sriov_agent_config('sriov_nic/exclude_devices').with_value('<SERVICE DEFAULT>')
        should contain_neutron_sriov_agent_config('sriov_nic/physical_device_mappings').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when supplying extensions for ML2 SR-IOV agent' do
      before :each do
        params.merge!(:extensions => ['qos'])
      end

      it 'configures extensions' do
        should contain_neutron_sriov_agent_config('agent/extensions').with_value(params[:extensions].join(','))
      end
    end

    context 'when parameters for resource providers are set' do
      before :each do
        params.merge!(
          :resource_provider_bandwidths         => ['provider-a', 'provider-b'],
          :resource_provider_hypervisors        => ['provider-a:compute-a', 'provider-b:compute-b'],
          :resource_provider_default_hypervisor => 'compute-c',
          :resource_provider_inventory_defaults => ['allocation_ratio:1.0', 'min_unit:1', 'step_size:1'],
        )
      end

      it 'configures resource providers' do
        should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_bandwidths').\
          with_value('provider-a,provider-b')
        should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_hypervisors').\
          with_value('provider-a:compute-a,provider-b:compute-b')
        should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_default_hypervisor').\
          with_value('compute-c')
        should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_inventory_defaults').\
          with_value('allocation_ratio:1.0,min_unit:1,step_size:1')
      end
    end

    context 'when parameters for resource providers are set by hash' do
      before :each do
        params.merge!(
          :resource_provider_inventory_defaults => {
            'allocation_ratio' => '1.0',
            'min_unit'         => '1',
            'step_size'        => '1'
          },
        )
      end

      it 'configures resource providers' do
        should contain_neutron_sriov_agent_config('sriov_nic/resource_provider_inventory_defaults').\
          with_value('allocation_ratio:1.0,min_unit:1,step_size:1')
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

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          {
            :sriov_nic_agent_package => 'neutron-sriov-agent',
            :sriov_nic_agent_service => 'neutron-sriov-agent'
          }
        when 'RedHat'
          {
            :sriov_nic_agent_package => 'openstack-neutron-sriov-nic-agent',
            :sriov_nic_agent_service => 'neutron-sriov-nic-agent'
          }
        end
      end

      it_behaves_like 'neutron sriov-nic agent with ml2 plugin'
    end
  end
end
