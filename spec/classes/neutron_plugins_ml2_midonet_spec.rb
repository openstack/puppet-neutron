require 'spec_helper'

describe 'neutron::plugins::ml2::midonet' do
  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2'
     }"
  end

  let :default_params do
    {
      :midonet_uri => 'http://localhost:8080/midonet-api',
      :username    => 'admin',
      :password    => 'passw0rd',
      :project_id  => 'admin',
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron ml2 midonet plugin' do
    before do
      params.merge!(default_params)
    end

    it { should contain_class('neutron::params') }

    it do
      should contain_neutron_plugin_ml2('MIDONET/midonet_uri').with_value(params[:midonet_uri])
      should contain_neutron_plugin_ml2('MIDONET/username').with_value(params[:username])
      should contain_neutron_plugin_ml2('MIDONET/password').with_value(params[:password])
      should contain_neutron_plugin_ml2('MIDONET/project_id').with_value(params[:project_id])
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
          {
            :midonet_ml2_config_file => '/etc/neutron/conf.d/neutron-server/ml2_mech_midonet.conf'
          }
        end
      end

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'neutron ml2 midonet plugin'
      end
    end
  end
end
