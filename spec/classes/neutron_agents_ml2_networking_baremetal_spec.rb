require 'spec_helper'

describe 'neutron::agents::ml2::networking_baremetal' do

  let :default_params do
    { :enabled             => true,
      :manage_service      => true,
      :package_ensure      => 'present',
      :auth_type           => 'password',
      :auth_url            => 'http://127.0.0.1:35357',
      :username            => 'ironic',
      :project_domain_id   => 'default',
      :project_domain_name => 'Default',
      :project_name        => 'services',
      :user_domain_id      => 'default',
      :user_domain_name    => 'Default',
      :purge_config        => false,
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  let :params do
    { :password => 'passw0rd',
    }
  end

  shared_examples_for 'networking-baremetal ironic-neutron-agent with ml2 plugin' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it 'passes purge to resource' do
      is_expected.to contain_resources('ironic_neutron_agent_config').with({
        :purge => false
      })
    end

    it 'configures /etc/neutron/plugins/ml2/ironic_neutron_agent.ini' do
      is_expected.to contain_ironic_neutron_agent_config('ironic/auth_strategy').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_neutron_agent_config('ironic/ironic_url').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_neutron_agent_config('ironic/cafile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_neutron_agent_config('ironic/certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_neutron_agent_config('ironic/keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_neutron_agent_config('ironic/auth_type').with_value(p[:auth_type])
      is_expected.to contain_ironic_neutron_agent_config('ironic/auth_url').with_value(p[:auth_url])
      is_expected.to contain_ironic_neutron_agent_config('ironic/username').with_value(p[:username])
      is_expected.to contain_ironic_neutron_agent_config('ironic/password').with_value(p[:password])
      is_expected.to contain_ironic_neutron_agent_config('ironic/project_domain_id').with_value(p[:project_domain_id])
      is_expected.to contain_ironic_neutron_agent_config('ironic/project_domain_name').with_value(p[:project_domain_name])
      is_expected.to contain_ironic_neutron_agent_config('ironic/project_name').with_value(p[:project_name])
      is_expected.to contain_ironic_neutron_agent_config('ironic/user_domain_id').with_value(p[:user_domain_id])
      is_expected.to contain_ironic_neutron_agent_config('ironic/user_domain_name').with_value(p[:user_domain_name])
      is_expected.to contain_ironic_neutron_agent_config('ironic/region_name').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_neutron_agent_config('ironic/retry_interval').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_neutron_agent_config('ironic/max_retries').with_value('<SERVICE DEFAULT>')
    end

    it 'installs ironic-neutron-agent agent package' do
      is_expected.to contain_package('python2-ironic-neutron-agent').with(
        :name   => platform_params[:networking_baremetal_agent_package],
        :ensure => p[:package_ensure],
        :tag    => ['openstack', 'neutron-package'],
      )
      is_expected.to contain_package('python2-ironic-neutron-agent').that_requires('Anchor[neutron::install::begin]')
      is_expected.to contain_package('python2-ironic-neutron-agent').that_notifies('Anchor[neutron::install::end]')
    end

    it 'configures networking-baremetal ironic-neutron-agent service' do
      is_expected.to contain_service('ironic-neutron-agent-service').with(
        :name    => platform_params[:networking_baremetal_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :tag     => 'neutron-service',
      )
      is_expected.to contain_service('ironic-neutron-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
      is_expected.to contain_service('ironic-neutron-agent-service').that_notifies('Anchor[neutron::service::end]')
    end

    context 'with enabled as false' do
      before :each do
        params.merge!(:enabled => false)
      end
      it 'should not start service' do
        is_expected.to contain_service('ironic-neutron-agent-service').with(
          :name    => platform_params[:networking_baremetal_agent_service],
          :enable  => false,
          :ensure  => 'stopped',
          :tag     => 'neutron-service',
        )
        is_expected.to contain_service('ironic-neutron-agent-service').that_subscribes_to('Anchor[neutron::service::begin]')
        is_expected.to contain_service('ironic-neutron-agent-service').that_notifies('Anchor[neutron::service::end]')
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
          { :networking_baremetal_agent_package => 'python2-ironic-neutron-agent',
            :networking_baremetal_agent_service => 'ironic-neutron-agent' }
        end
      end
      case facts[:osfamily]
      when 'RedHat'
        it_behaves_like 'networking-baremetal ironic-neutron-agent with ml2 plugin'
      when facts[:osfamily] != 'RedHat'
        it 'fails with unsupported osfamily' do
          is_expected.to raise_error(Puppet::Error, /Unsupported osfamily.*/)
        end
      end
    end
  end

end
