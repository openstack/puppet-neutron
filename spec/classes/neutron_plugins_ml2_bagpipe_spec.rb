require 'spec_helper'

describe 'neutron::plugins::ml2::bagpipe' do

  let :params do
    {}
  end

  shared_examples 'neutron plugin bagpipe ml2' do

    it 'should have' do
      should contain_package('python-networking-bagpipe').with(
        :ensure => 'present',
        :name   => platform_params[:bagpipe_package_name],
        :tag    => ['openstack', 'neutron-plugin-ml2-package']
        )
    end

    it 'configures bagpipe settings' do
      should contain_neutron_plugin_ml2('bagpipe/bagpipe_bgp_port').with_value('<SERVICE DEFAULT>')
      should contain_neutron_plugin_ml2('bagpipe/mpls_bridge').with_value('<SERVICE DEFAULT>')
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
        case facts[:os]['family']
        when 'Debian'
          { :bagpipe_package_name => 'python3-networking-bagpipe' }
        when 'RedHat'
          { :bagpipe_package_name => 'python3-networking-bagpipe' }
        end
      end
      it_behaves_like 'neutron plugin bagpipe ml2'
    end
  end
end
