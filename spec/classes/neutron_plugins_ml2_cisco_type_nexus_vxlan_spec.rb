#
# Unit tests for neutron::plugins::ml2::cisco::type_nexus_vxlan class
#

require 'spec_helper'

describe 'neutron::plugins::ml2::cisco::type_nexus_vxlan' do

  let :pre_condition do
    "class { 'neutron::server': password => 'password'}
     class { 'neutron':
      rabbit_password => 'passw0rd',
      core_plugin     => 'neutron.plugins.ml2.plugin.Ml2Plugin' }"
  end

  let :default_params do
    {
      :vni_ranges => '20000:22000',
      :mcast_ranges => '224.0.0.1:224.0.0.3,224.0.1.1:224.0.1.3'
    }
  end

  let :params do
    {}
  end

  let :test_facts do
    { :operatingsystem         => 'default',
      :operatingsystemrelease  => 'default',
      :concat_basedir          => '/',
    }
  end

  shared_examples_for 'neutron cisco ml2 type nexus vxlan plugin' do

    before do
      params.merge!(default_params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it do
      is_expected.to contain_neutron_plugin_ml2('ml2_type_nexus_vxlan/vni_ranges').with_value(params[:vni_ranges])
      is_expected.to contain_neutron_plugin_ml2('ml2_type_nexus_vxlan/mcast_ranges').with_value(params[:mcast_ranges])
    end

  end

  begin
    context 'on RedHat platforms' do
      let :facts do
        @default_facts.merge(test_facts.merge({
           :osfamily               => 'RedHat',
           :operatingsystemrelease => '7'
        }))
      end

      it_configures 'neutron cisco ml2 type nexus vxlan plugin'
    end
  end
end
