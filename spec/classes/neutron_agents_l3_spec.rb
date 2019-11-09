require 'spec_helper'

describe 'neutron::agents::l3' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :default_params do
    {
      :package_ensure     => 'present',
      :enabled            => true,
      :interface_driver   => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :ha_enabled         => false,
      :ha_vrrp_auth_type  => 'PASS',
      :ha_vrrp_advert_int => '3',
      :agent_mode         => 'legacy',
      :purge_config       => false
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron l3 agent' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'configures l3_agent.ini' do
      should contain_neutron_l3_agent_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver])
      should contain_neutron_l3_agent_config('DEFAULT/gateway_external_network_id').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/handle_internal_only_routers').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/metadata_port').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/periodic_interval').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/periodic_fuzzy_delay').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/enable_metadata_proxy').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('DEFAULT/radvd_user').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('agent/availability_zone').with_value('<SERVICE DEFAULT>')
      should contain_neutron_l3_agent_config('agent/extensions').with_value('<SERVICE DEFAULT>')
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_l3_agent_config').with({
        :purge => false
      })
    end

    it 'installs neutron l3 agent package' do
      if platform_params.has_key?(:l3_agent_package)
        should contain_package('neutron-l3').with(
          :name    => platform_params[:l3_agent_package],
          :ensure  => p[:package_ensure],
          :tag     => ['openstack', 'neutron-package'],
        )
        should contain_package('neutron-l3').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron-l3').that_notifies('Anchor[neutron::install::end]')
      else
        should contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        should contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    context 'with manage_service as true' do
      before :each do
        params.merge!(:manage_service => true)
      end
      it 'configures neutron l3 agent service' do
        should contain_service('neutron-l3').with(
          :name    => platform_params[:l3_agent_service],
          :enable  => true,
          :ensure  => 'running',
          :tag     => 'neutron-service',
        )
        should contain_service('neutron-l3').that_subscribes_to('Anchor[neutron::service::begin]')
        should contain_service('neutron-l3').that_notifies('Anchor[neutron::service::end]')
      end
    end

    context 'with DVR' do
      before :each do
        params.merge!(:agent_mode => 'dvr')
      end
      it 'should enable DVR mode' do
        should contain_neutron_l3_agent_config('DEFAULT/agent_mode').with_value(p[:agent_mode])
      end
    end

    context 'with radvd user' do
      before :each do
        params.merge!(:radvd_user => 'root')
      end

      it 'configures radvd user' do
        should contain_neutron_l3_agent_config('DEFAULT/radvd_user').with_value(p[:radvd_user])
      end
    end

    context 'with HA routers' do
      before :each do
        params.merge!(:ha_enabled            => true,
                      :ha_vrrp_auth_password => 'secrete')
      end
      it 'should configure VRRP' do
        should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_type').with_value(p[:ha_vrrp_auth_type])
        should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_password').with_value(p[:ha_vrrp_auth_password])
        should contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_advert_int').with_value(p[:ha_vrrp_advert_int])
      end
    end

    context 'with availability zone' do
      before :each do
        params.merge!(:availability_zone => 'zone1')
      end

      it 'configures availability zone' do
        should contain_neutron_l3_agent_config('agent/availability_zone').with_value(p[:availability_zone])
      end
    end
  end

  shared_examples 'neutron::agents::l3 on Debian' do
    it 'configures neutron-l3 package subscription' do
      should contain_service('neutron-l3').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-l3').that_notifies('Anchor[neutron::service::end]')
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
            :l3_agent_package => 'neutron-l3-agent',
            :l3_agent_service => 'neutron-l3-agent'
          }
        when 'RedHat'
          {
            :l3_agent_service => 'neutron-l3-agent'
          }
        end
      end

      it_behaves_like 'neutron l3 agent'
    end
  end
end
