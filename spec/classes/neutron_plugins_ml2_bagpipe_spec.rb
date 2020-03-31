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
    {}
  end

  shared_examples 'neutron plugin bagpipe ml2' do
    before do
      params.merge!(default_params)
    end

    it 'should have' do
      should contain_package('python-networking-bagpipe').with(
        :name   => platform_params[:bagpipe_package_name],
        :ensure => params[:package_ensure],
        :tag    => 'openstack'
        )
    end

    it 'configures bagpipe settings' do
      should contain_neutron_plugin_ml2('bagpipe/bagpipe_bgp_port').with_value(params[:bagpipe_bgp_port])
      should contain_neutron_plugin_ml2('bagpipe/mpls_bridge').with_value(params[:mpls_bridge])
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
        when 'Debian'
          { :bagpipe_package_name => 'python3-networking-bagpipe' }
        when 'RedHat'
          if facts[:operatingsystem] == 'Fedora'
            { :bagpipe_package_name => 'python3-networking-bagpipe' }
          else
            if facts[:operatingsystemmajrelease] > '7'
              { :bagpipe_package_name => 'python3-networking-bagpipe' }
            else
              { :bagpipe_package_name => 'python-networking-bagpipe' }
            end
          end
        end
      end
      it_behaves_like 'neutron plugin bagpipe ml2'
    end
  end
end
