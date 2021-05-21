# Copyright (C) 2017 Red Hat Inc.
#
# Author: Tim Rozet <trozet@redhat.com>
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

describe 'neutron::services::sfc' do
  let :default_params do
    { :package_ensure => 'present',
      :sfc_driver     => '<SERVICE DEFAULT>',
      :fc_driver     => '<SERVICE DEFAULT>',
      :sync_db        => true,
    }
  end

  shared_examples 'neutron sfc service plugin' do

    context 'with default params' do
      let :params do
        default_params
      end

      it 'installs sfc package' do
        should contain_package(platform_params[:sfc_package_name]).with(
          :ensure => params[:package_ensure],
          :name   => platform_params[:sfc_package_name],
        )
      end

      it 'runs neutron-db-sync' do
        should contain_exec('sfc-db-sync').with(
          :command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --subproject networking-sfc upgrade head',
          :path        => '/usr/bin',
          :subscribe   => ['Anchor[neutron::install::end]',
                           'Anchor[neutron::config::end]',
                           'Anchor[neutron::dbsync::begin]'
                           ],
          :notify      => 'Anchor[neutron::dbsync::end]',
          :refreshonly => 'true',
        )
      end
    end

    context 'with sfc and classifier drivers' do
      let :params do
        default_params.merge(
          { :sfc_driver => 'odl_v2',
            :fc_driver  => 'odl_v2'
          }
        )
      end

      it 'configures networking-sfc.conf' do
        should contain_neutron_sfc_service_config(
          'sfc/drivers'
        ).with_value('odl_v2')
        should contain_neutron_sfc_service_config(
          'flowclassifier/drivers'
        ).with_value('odl_v2')
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
        when 'Debian'
          { :sfc_package_name => 'python3-networking-sfc' }
        when 'RedHat'
          { :sfc_package_name => 'python3-networking-sfc' }
        end
      end
      it_behaves_like 'neutron sfc service plugin'
    end
  end
end
