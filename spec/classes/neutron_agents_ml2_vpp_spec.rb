require 'spec_helper'

describe 'neutron::agents::ml2::vpp' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  let :default_params do
    { :package_ensure => 'present',
      :enabled        => true,
      :manage_service => true,
      :etcd_host      => '127.0.0.1',
      :etcd_port      => 4001,
      }
  end

  let :params do
    {}
  end

  shared_examples_for 'neutron plugin vpp agent with ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_agent_vpp').with({
        :purge => false
      })
    end

    it 'configures plugins/ml2/vpp_agent.ini' do
      is_expected.to contain_neutron_agent_vpp('ml2_vpp/physnets').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_agent_vpp('ml2_vpp/etcd_user').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_neutron_agent_vpp('ml2_vpp/etcd_pass').with_value('<SERVICE DEFAULT>')
    end

    it 'installs neutron vpp agent package' do
      is_expected.to contain_package('neutron-vpp-agent').with(
        :name   => platform_params[:vpp_plugin_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
    end

    it 'configures neutron vpp agent service' do
      is_expected.to contain_service('neutron-vpp-agent-service').with(
        :name    => platform_params[:vpp_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => ['neutron-service'],
      )
      is_expected.to contain_service('neutron-vpp-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('neutron-vpp-agent-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not start/stop service' do
        is_expected.to contain_service('neutron-vpp-agent-service').without_ensure
      end
    end

    context 'when supplying a physnet mapping' do
      before :each do
        params.merge!(:physnets => 'physnet:GigabitEthernet2/2/0')
      end
      it 'should configure physnets' do
        is_expected.to contain_neutron_agent_vpp('ml2_vpp/physnets').with_value('physnet:GigabitEthernet2/2/0')
      end
    end

    context 'when enabling etcd authentication' do
      before :each do
        params.merge!(:etcd_user => 'admin',
                      :etcd_pass => 'password' )
      end
      it 'should configure etcd username and password' do
        is_expected.to contain_neutron_agent_vpp('ml2_vpp/etcd_user').with_value('admin')
        is_expected.to contain_neutron_agent_vpp('ml2_vpp/etcd_pass').with_value('password')
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

      let :platform_params do
        { :vpp_plugin_package => 'python-networking-vpp',
          :vpp_agent_service => 'neutron-vpp-agent' }
      end

      it_behaves_like 'neutron plugin vpp agent with ml2 plugin'
    end
  end
end
