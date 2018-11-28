require 'spec_helper'

describe 'neutron::agents::lbaas' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present',
      :enabled          => true,
      :interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :device_driver    => 'neutron_lbaas.drivers.haproxy.namespace_driver.HaproxyNSDriver',
      :manage_haproxy_package  => true,
      :purge_config            => false
    }
  end

  shared_examples 'neutron lbaas agent' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it_behaves_like 'haproxy lbaas_driver'
    it_behaves_like 'haproxy lbaas_driver without package'

    it 'passes purge to resource' do
      should contain_resources('neutron_lbaas_agent_config').with({
        :purge => false
      })
    end

    it 'configures lbaas_agent.ini' do
      should contain_neutron_lbaas_agent_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>');
      should contain_neutron_lbaas_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      should contain_neutron_lbaas_agent_config('DEFAULT/device_driver').with_value(p[:device_driver]);
      should contain_neutron_lbaas_agent_config('haproxy/user_group').with_value(platform_params[:nobody_user_group]);
      should contain_neutron_lbaas_agent_config('DEFAULT/ovs_use_veth').with_value('<SERVICE DEFAULT>');
    end

    it 'installs neutron lbaas agent package' do
      should contain_package('neutron-lbaasv2-agent').with(
        :name   => platform_params[:lbaas_agent_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      should contain_package('neutron').with_before(/Package\[neutron-lbaasv2-agent\]/)
    end

    it 'configures neutron lbaas agent service' do
      should contain_service('neutron-lbaasv2-service').with(
        :name    => platform_params[:lbaas_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('neutron-lbaasv2-service').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-lbaasv2-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        should contain_service('neutron-lbaasv2-service').with(
          :ensure => 'stopped',
        )
      end
    end

    context 'with ovs_use_veth as false' do
      before :each do
        params.merge!(:ovs_use_veth => false)
      end
      it 'should have ovs_use_veth set to false' do
        should contain_neutron_lbaas_agent_config('DEFAULT/ovs_use_veth').with_value(false);
      end
    end

    context 'with device_driver as $::os_service_default' do
      before :each do
        params.merge!(:device_driver => '<SERVICE DEFAULT>')
      end
      it 'should have devcie_driver set to $::os_service_default' do
        should contain_neutron_lbaas_agent_config('DEFAULT/device_driver').with_value('<SERVICE DEFAULT>');
      end
    end
  end

  shared_examples 'haproxy lbaas_driver' do
    it 'installs haproxy packages' do
      if platform_params.has_key?(:lbaas_agent_package)
        should contain_package(platform_params[:haproxy_package]).with_before(['Package[neutron-lbaasv2-agent]'])
      end
      should contain_package(platform_params[:haproxy_package]).with(
        :ensure => 'present'
      )
    end
  end

  shared_examples 'haproxy lbaas_driver without package' do
    let :pre_condition do
      "package { 'haproxy':
         ensure => 'present'
       }
      class { 'neutron': }"
    end
    before do
      params.merge!(:manage_haproxy_package => false)
    end
    it 'installs haproxy package via haproxy module' do
      should contain_package(platform_params[:haproxy_package]).with(
        :ensure => 'present'
      )
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts( :concat_basedir => '/dne' ))
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :haproxy_package     =>  'haproxy',
            :lbaas_agent_package => 'neutron-lbaasv2-agent',
            :nobody_user_group   => 'nogroup',
            :lbaas_agent_service => 'neutron-lbaasv2-agent'
          }
        when 'RedHat'
          {
            :haproxy_package     => 'haproxy',
            :lbaas_agent_package => 'openstack-neutron-lbaas',
            :nobody_user_group   => 'nobody',
            :lbaas_agent_service => 'neutron-lbaasv2-agent'
          }
        end
      end

      it_behaves_like 'neutron lbaas agent'
    end
  end
end
