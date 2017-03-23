# Copyright (C) 2017 Red Hat Inc.
#
# Author: Ricardo Noriega <rnoriega@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'neutron::agents::bagpipe' do

  let :params do
    { :my_as                            => 64512,
      :api_port                         => 8082,
      :dataplane_driver_ipvpn           => 'ovs',
      :enabled                          => true,
      :enable_rtc                       => true,
      :manage_service                   => true,
      :mpls_interface                   => '*gre*',
      :ovs_bridge                       => 'br-mpls',
      :package_ensure                   => 'present',
      :peers                            => '192.168.0.101',
      :proxy_arp                        => false,
      :purge_config                     => false,
      :local_address                    => '127.0.0.1'
    }
  end

  let :default_params do
    {}
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end
  shared_examples_for 'neutron bgpvpn bagpipe agent' do
    let :p do
      default_params.merge(params)
    end

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_bgpvpn_bagpipe_config').with({
        :purge => false
      })
    end

    it 'installs bgpvpn bagpipe package' do
      is_expected.to contain_package('python-networking-bagpipe').with(
        :ensure => p[:package_ensure],
        :name   => platform_params[:bgpvpn_bagpipe_package],
      )
    end

    it 'configures bgp.conf' do
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('api/port').with_value(p[:api_port])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('bgp/local_address').with_value(p[:local_address])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('bgp/peers').with_value(p[:peers])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('bgp/my_as').with_value(p[:my_as])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('bgp/enable_rtc').with_value(p[:enable_rtc])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('dataplane_driver_ipvpn/dataplane_driver').with_value(p[:dataplane_driver_ipvpn])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('dataplane_driver_ipvpn/ovs_bridge').with_value(p[:ovs_bridge])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('dataplane_driver_ipvpn/proxy_arp').with_value(p[:proxy_arp])
      is_expected.to contain_neutron_bgpvpn_bagpipe_config('dataplane_driver_ipvpn/mpls_interface').with_value(p[:mpls_interface])
    end

    it 'bagpipe service running' do
      is_expected.to contain_service('bagpipe-bgp').with_ensure('running')
    end

    context 'with multiple peers' do
      before :each do
        params.merge!(
          { :peers => ['peer1', 'peer2'] }
        )
      end

      it 'configures multiple peers in bgp.conf' do
        is_expected.to contain_neutron_bgpvpn_bagpipe_config(
          'bgp/peers'
        ).with_value(p[:peers].join(','))
      end
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
          { :bgpvpn_bagpipe_package => 'python-networking-bagpipe' }
        when 'Debian'
          { :bgpvpn_bagpipe_package => 'python-networking-bagpipe' }
        end
      end

      it_configures 'neutron bgpvpn bagpipe agent'
    end
  end
end
