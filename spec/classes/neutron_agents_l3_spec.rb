require 'spec_helper'

describe 'neutron::agents::l3' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :default_params do
    { :package_ensure                   => 'present',
      :enabled                          => true,
      :debug                            => false,
      :interface_driver                 => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :ha_enabled                       => false,
      :ha_vrrp_auth_type                => 'PASS',
      :ha_vrrp_advert_int               => '3',
      :agent_mode                       => 'legacy',
      :purge_config                     => false }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  let :params do
    { }
  end

  shared_examples_for 'neutron l3 agent' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'configures l3_agent.ini' do
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/debug').with_value(p[:debug])
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/external_network_bridge').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver])
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/gateway_external_network_id').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/handle_internal_only_routers').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/metadata_port').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/send_arp_for_ha').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/periodic_interval').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/periodic_fuzzy_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('DEFAULT/enable_metadata_proxy').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_l3_agent_config('AGENT/availability_zone').with_value('<SERVICE DEFAULT>')
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_l3_agent_config').with({
        :purge => false
      })
    end

    it 'installs neutron l3 agent package' do
      if platform_params.has_key?(:l3_agent_package)
        is_expected.to contain_package('neutron-l3').with(
          :name    => platform_params[:l3_agent_package],
          :ensure  => p[:package_ensure],
          :tag     => ['openstack', 'neutron-package'],
        )
        is_expected.to contain_package('neutron-l3').that_requires('Anchor[neutron::install::begin]')
        is_expected.to contain_package('neutron-l3').that_notifies('Anchor[neutron::install::end]')
      else
        is_expected.to contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        is_expected.to contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end

    context 'with manage_service as true' do
      before :each do
        params.merge!(:manage_service => true)
      end
      it 'configures neutron l3 agent service' do
        is_expected.to contain_service('neutron-l3').with(
          :name    => platform_params[:l3_agent_service],
          :enable  => true,
          :ensure  => 'running',
          :tag     => 'neutron-service',
        )
        is_expected.to contain_service('neutron-l3').that_subscribes_to('Anchor[neutron::service::begin]')
        is_expected.to contain_service('neutron-l3').that_notifies('Anchor[neutron::service::end]')
      end
    end

    context 'with DVR' do
      before :each do
        params.merge!(:agent_mode => 'dvr')
      end
      it 'should enable DVR mode' do
        is_expected.to contain_neutron_l3_agent_config('DEFAULT/agent_mode').with_value(p[:agent_mode])
      end
    end

    context 'with HA routers' do
      before :each do
        params.merge!(:ha_enabled            => true,
                      :ha_vrrp_auth_password => 'secrete')
      end
      it 'should configure VRRP' do
        is_expected.to contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_type').with_value(p[:ha_vrrp_auth_type])
        is_expected.to contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_auth_password').with_value(p[:ha_vrrp_auth_password])
        is_expected.to contain_neutron_l3_agent_config('DEFAULT/ha_vrrp_advert_int').with_value(p[:ha_vrrp_advert_int])
      end
    end

    context 'with availability zone' do
      before :each do
        params.merge!(:availability_zone => 'zone1')
      end

      it 'configures availability zone' do
        is_expected.to contain_neutron_l3_agent_config('AGENT/availability_zone').with_value(p[:availability_zone])
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
      { :l3_agent_package => 'neutron-l3-agent',
        :l3_agent_service => 'neutron-l3-agent' }
    end

    it_configures 'neutron l3 agent'
    it 'configures neutron-l3 package subscription' do
      is_expected.to contain_service('neutron-l3').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('neutron-l3').that_notifies('Anchor[neutron::service::end]')
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily               => 'RedHat',
         :operatingsystemrelease => '7'
      }))
    end

    let :platform_params do
      { :l3_agent_service => 'neutron-l3-agent' }
    end

    it_configures 'neutron l3 agent'
  end
end
