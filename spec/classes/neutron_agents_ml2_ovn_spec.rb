require 'spec_helper'

describe 'neutron::agents::ml2::ovn' do
  let :pre_condition do
    "class { 'neutron': }"
  end

  shared_examples 'OVN Neutron Agent' do
    it { should contain_class('neutron::params') }

    it 'configures OVN Neutron Agent service' do
      should contain_service('neutron-ovn-agent').with(
        :name    => platform_params[:neutron_ovn_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('neutron-ovn-agent').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-ovn-agent').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with manage_service as false' do
      let :params do
        { :manage_service => false }
      end

      it 'should not manage the service' do
        should_not contain_service('neutron-ovn-agent')
      end
    end

    it 'passes purge to resource' do
      should contain_resources('neutron_agent_ovn').with({
        :purge => false
      })
    end

    it 'configures ovn_agent.ini' do
      should contain_neutron_agent_ovn('DEFAULT/debug').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('DEFAULT/state_path').with(:value => '/var/lib/neutron')
      should contain_neutron_agent_ovn('agent/root_helper').with(:value => 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf')
      should contain_neutron_agent_ovn('agent/root_helper_daemon').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('ovs/ovsdb_connection').with(:value => 'tcp:127.0.0.1:6640')
      should contain_neutron_agent_ovn('ovs/ovsdb_connection_timeout').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('ovn/ovsdb_connection_timeout').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('ovn/ovn_nb_connection').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('ovn/ovn_sb_connection').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('ovn/ovsdb_retry_max_interval').with(:value => '<SERVICE DEFAULT>')
      should contain_neutron_agent_ovn('ovn/ovsdb_probe_interval').with(:value => '<SERVICE DEFAULT>')
    end

    it 'installs OVN Neutron Agent package' do
      should contain_package('neutron-ovn-agent').with(
        :ensure => 'present',
        :name   => platform_params[:neutron_ovn_agent_package],
        :tag    => ['openstack', 'neutron-package'],
      )
    end

    it 'configures subscription to neutron-ovn-agent package' do
      should contain_service('neutron-ovn-agent').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('neutron-ovn-agent').that_notifies('Anchor[neutron::service::end]')
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
          { :neutron_ovn_agent_package => 'neutron-ovn-agent',
            :neutron_ovn_agent_service => 'neutron-ovn-agent' }
        when 'RedHat'
          { :neutron_ovn_agent_package => 'openstack-neutron-ovn-agent',
            :neutron_ovn_agent_service => 'neutron-ovn-agent' }
        end
      end

      it_behaves_like 'OVN Neutron Agent'
    end
  end
end
