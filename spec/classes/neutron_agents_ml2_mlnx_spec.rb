require 'spec_helper'

describe 'neutron::agents::ml2::mlnx' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {}
  end

  shared_examples 'neutron mlnx agent with ml2 plugin' do
    it { should contain_class('neutron::params') }


    it 'configures /etc/neutron/plugins/mlnx/mlnx_config.ini' do
      should contain_neutron_mlnx_agent_config('eswitch/physical_interface_mappings').with_value('<SERVICE DEFAULT>')
    end


    it 'installs neutron mlnx agent package' do
      should contain_package(platform_params[:mlnx_agent_package]).with(
        :name   => platform_params[:mlnx_agent_package],
        :ensure => 'installed',
        :tag    => platform_params[:mlnx_agent_package_tag]
      )

      if platform_params[:eswitchd_package]
        should contain_package(platform_params[:eswitchd_package]).with(
          :name   => platform_params[:eswitchd_package],
          :ensure => 'installed',
          :tag    => ['openstack', 'neutron-package'],
        )
      end
    end

    it 'configures neutron mlnx agent service' do
      should contain_service(platform_params[:mlnx_agent_service]).with(
        :name    => platform_params[:mlnx_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service(platform_params[:eswitchd_service]).with(
        :name    => platform_params[:eswitchd_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not manage the  services' do
        should_not contain_service(platform_params[:mlnx_agent_service])
        should_not contain_service(platform_params[:eswitchd_service])
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
      should contain_neutron_dhcp_agent_config('DEFAULT/multi_interface_driver_mappings').with_value('<SERVICE DEFAULT>')
      should contain_neutron_dhcp_agent_config('DEFAULT/ipoib_physical_interface').with_value('<SERVICE DEFAULT>')
      should contain_neutron_dhcp_agent_config('DEFAULT/enable_multi_interface_driver_cache_maintenance').with_value(false)
    end

    it 'configures neutron l3 agent' do
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
        case facts[:os]['family']
        when 'Debian'
          {
            :mlnx_agent_package     => 'neutron-mlnx-agent',
            :mlnx_agent_service     => 'neutron-mlnx-agent',
            :eswitchd_package       => 'networking-mlnx-eswitchd',
            :eswitchd_service       => 'networking-mlnx-eswitchd',
            :mlnx_agent_package_tag => ['openstack', 'neutron-package'],
          }
        when 'RedHat'
          {
            :mlnx_agent_package     => 'python3-networking-mlnx',
            :mlnx_agent_service     => 'neutron-mlnx-agent',
            :eswitchd_package       => false,
            :eswitchd_service       => 'eswitchd',
            :mlnx_agent_package_tag => ['openstack', 'neutron-plugin-ml2-package'],
          }
        end
      end

      it_behaves_like 'neutron mlnx agent with ml2 plugin'
    end
  end
end
