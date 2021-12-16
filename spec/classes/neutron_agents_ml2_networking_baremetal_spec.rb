require 'spec_helper'

describe 'neutron::agents::ml2::networking_baremetal' do
  let :default_params do
    {
      :enabled             => true,
      :manage_service      => true,
      :package_ensure      => 'present',
      :auth_type           => 'password',
      :auth_url            => 'http://127.0.0.1:5000',
      :username            => 'ironic',
      :project_domain_name => 'Default',
      :project_name        => 'services',
      :user_domain_name    => 'Default',
      :purge_config        => false,
    }
  end

  let :params do
    {
      :password => 'passw0rd',
    }
  end

  shared_examples 'networking-baremetal ironic-neutron-agent with ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('neutron::params') }

    it 'passes purge to resource' do
      should contain_resources('ironic_neutron_agent_config').with({
        :purge => false
      })
    end

    it 'configures /etc/neutron/plugins/ml2/ironic_neutron_agent.ini' do
      should contain_ironic_neutron_agent_config('ironic/endpoint_override').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('ironic/cafile').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('ironic/certfile').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('ironic/keyfile').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('ironic/auth_type').with_value(p[:auth_type])
      should contain_ironic_neutron_agent_config('ironic/auth_url').with_value(p[:auth_url])
      should contain_ironic_neutron_agent_config('ironic/user_domain_name').with_value(p[:user_domain_name])
      should contain_ironic_neutron_agent_config('ironic/username').with_value(p[:username])
      should contain_ironic_neutron_agent_config('ironic/password').with_value(p[:password]).with_secret(true)
      should contain_ironic_neutron_agent_config('ironic/project_domain_name').with_value(p[:project_domain_name])
      should contain_ironic_neutron_agent_config('ironic/project_name').with_value(p[:project_name])
      should contain_ironic_neutron_agent_config('ironic/system_scope').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('ironic/region_name').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('ironic/status_code_retry_delay').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('ironic/status_code_retries').with_value('<SERVICE DEFAULT>')
      should contain_ironic_neutron_agent_config('agent/report_interval').with_value('<SERVICE DEFAULT>')
    end

    it 'installs ironic-neutron-agent agent package' do
      should contain_package('python-ironic-neutron-agent').with(
        :name   => platform_params[:networking_baremetal_agent_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      should contain_package('python-ironic-neutron-agent').that_requires('Anchor[neutron::install::begin]')
      should contain_package('python-ironic-neutron-agent').that_notifies('Anchor[neutron::install::end]')
    end

    it 'configures networking-baremetal ironic-neutron-agent service' do
      should contain_service('ironic-neutron-agent-service').with(
        :name    => platform_params[:networking_baremetal_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      should contain_service('ironic-neutron-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
      should contain_service('ironic-neutron-agent-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with enabled as false' do
      before :each do
        params.merge!(:enabled => false)
      end
      it 'should not start service' do
        should contain_service('ironic-neutron-agent-service').with(
          :name    => platform_params[:networking_baremetal_agent_service],
          :enable  => false,
          :ensure  => 'stopped',
          :tag     => 'neutron-service',
        )
        should contain_service('ironic-neutron-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
        should contain_service('ironic-neutron-agent-service').that_notifies('Anchor[neutron::service::end]')
      end
    end

    context 'when system_scope is set' do
      before :each do
        params.merge!(
          :system_scope => 'all'
        )
      end

      it 'should configure system scope credential' do
        should contain_ironic_neutron_agent_config('ironic/project_domain_name').with_value('<SERVICE DEFAULT>')
        should contain_ironic_neutron_agent_config('ironic/project_name').with_value('<SERVICE DEFAULT>')
        should contain_ironic_neutron_agent_config('ironic/system_scope').with_value('all')
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
        case facts[:osfamily]
        when 'RedHat'
          { :networking_baremetal_agent_package => 'python3-ironic-neutron-agent',
            :networking_baremetal_agent_service => 'ironic-neutron-agent' }
        end
      end
      case facts[:osfamily]
      when 'RedHat'
        it_behaves_like 'networking-baremetal ironic-neutron-agent with ml2 plugin'
      when facts[:osfamily] != 'RedHat'
        it 'fails with unsupported osfamily' do
          should raise_error(Puppet::Error, /Unsupported osfamily.*/)
        end
      end
    end
  end
end
