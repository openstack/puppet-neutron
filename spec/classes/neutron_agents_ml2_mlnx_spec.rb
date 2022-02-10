require 'spec_helper'

describe 'neutron::agents::ml2::mlnx' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :default_params do
    {
      :package_ensure => 'present',
      :enabled        => true,
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron mlnx agent with ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }


    it 'configures /etc/neutron/plugins/mlnx/mlnx_config.ini' do
      should contain_neutron_mlnx_agent_config('eswitch/physical_interface_mappings').with_value('<SERVICE DEFAULT>')
    end


    it 'installs neutron mlnx agent package' do
      should contain_package(platform_params[:mlnx_agent_package]).with(
        :name   => platform_params[:mlnx_agent_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      should contain_package(platform_params[:mlnx_agent_package]).that_requires('Anchor[neutron::install::begin]')
      should contain_package(platform_params[:mlnx_agent_package]).that_notifies('Anchor[neutron::install::end]')
    end

    it 'configures neutron mlnx agent service' do
      should contain_service(platform_params[:mlnx_agent_service]).with(
        :name    => platform_params[:mlnx_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service(platform_params[:mlnx_agent_service]).that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service(platform_params[:mlnx_agent_service]).that_notifies('Anchor[neutron::service::end]')
      should contain_service('eswitchd').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('eswitchd').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not manage the  services' do
        should_not contain_service(platform_params[:mlnx_agent_service])
        should_not contain_service('eswitchd')
      end
    end

    context 'when supplying device mapping' do
      before :each do
        params.merge!(:physical_interface_mappings => ['physnet1:eth1'])
      end

      it 'configures physical device mappings' do
        should contain_neutron_mlnx_agent_config('eswitch/physical_interface_mappings').with_value(['physnet1:eth1'])
        should contain_eswitchd_config('DAEMON/fabrics').with_value(['physnet1:eth1'])
      end
    end

    context 'when supplying empty device mapping' do
      before :each do
        params.merge!(:physical_interface_mappings => "")
      end

      it 'configures physical device mappings with exclusion' do
        should contain_neutron_mlnx_agent_config('eswitch/physical_interface_mappings').with_value('<SERVICE DEFAULT>')
        should contain_eswitchd_config('DAEMON/fabrics').with_value('<SERVICE DEFAULT>')
      end
    end

    it 'configures neutron dhcp agent' do
      should contain_neutron_dhcp_agent_config('DEFAULT/dhcp_broadcast_reply').with_value('<SERVICE DEFAULT>')
      should contain_neutron_dhcp_agent_config('DEFAULT/interface_driver').with_value('<SERVICE DEFAULT>')
      should contain_neutron_dhcp_agent_config('DEFAULT/multi_interface_driver_mappings').with_value('<SERVICE DEFAULT>')
      should contain_neutron_dhcp_agent_config('DEFAULT/ipoib_physical_interface').with_value('<SERVICE DEFAULT>')
      should contain_neutron_dhcp_agent_config('DEFAULT/enable_multi_interface_driver_cache_maintenance').with_value(false)
    end

    it 'configures neutron l3 agent' do
      should contain_neutron_l3_agent_config('DEFAULT/interface_driver').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/multi_interface_driver_mappings').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/ipoib_physical_interface').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/enable_multi_interface_driver_cache_maintenance').with_value(false)
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
          {
            :mlnx_agent_package => 'python3-networking-mlnx',
            :mlnx_agent_service => 'neutron-plugin-mlnx-agent'
          }
        when 'RedHat'
          {
            :mlnx_agent_package => 'python3-networking-mlnx',
            :mlnx_agent_service => 'neutron-mlnx-agent'
          }
        end
      end

      it_behaves_like 'neutron mlnx agent with ml2 plugin'
    end
  end
end
