require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::type_nexus_vxlan' do
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
      :vni_ranges   => '20000:22000',
      :mcast_ranges => '224.0.0.1:224.0.0.3,224.0.1.1:224.0.1.3'
    }
  end

  let :params do
    {}
  end

  shared_examples 'neutron cisco ml2 type nexus vxlan plugin' do
    before do
      params.merge!(default_params)
    end

    it { should contain_class('neutron::params') }

    it do
      should contain_neutron_plugin_ml2('ml2_type_nexus_vxlan/vni_ranges').with_value(params[:vni_ranges])
      should contain_neutron_plugin_ml2('ml2_type_nexus_vxlan/mcast_ranges').with_value(params[:mcast_ranges])
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'neutron cisco ml2 type nexus vxlan plugin'
      end
    end
  end
end
