require 'spec_helper'

describe 'neutron::plugins::ml2::bagpipe' do

  let :default_params do
    {
      :bagpipe_bgp_port        => '<SERVICE DEFAULT>',
      :mpls_bridge             => '<SERVICE DEFAULT>',
      :package_ensure          => 'present',
    }
  end

  let :params do
    {
    }
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
    }
  end


  shared_examples_for 'neutron plugin bagpipe ml2' do
    before do
      params.merge!(default_params)
    end

    it 'should have' do
      is_expected.to contain_package('python-networking-bagpipe').with(
        :ensure => params[:package_ensure],
        :tag    => 'openstack'
        )
    end

    it 'configures bagpipe settings' do
      is_expected.to contain_neutron_plugin_ml2('bagpipe/bagpipe_bgp_port').with_value(params[:bagpipe_bgp_port])
      is_expected.to contain_neutron_plugin_ml2('bagpipe/mpls_bridge').with_value(params[:mpls_bridge])
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'RedHat'
          { :bagpipe_package_name => 'python-networking-bagpipe' }
        when 'Debian'
          { :bagpipe_package_name => 'python-networking-bagpipe' }
        end
      end
      it_configures 'neutron plugin bagpipe ml2'
    end
  end
end
