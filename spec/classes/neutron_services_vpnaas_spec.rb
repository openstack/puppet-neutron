#
# Copyright (C) 2014 Red Hat Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for neutron::services::vpnaas class
#

require 'spec_helper'

describe 'neutron::services::vpnaas' do
  let :default_params do
    {
      :package_ensure    => 'present',
      :service_providers => '<SERVICE DEFAULT>'
    }
  end

  shared_examples 'neutron vpnaas service plugin' do
    context 'with default params' do
      let :params do
        default_params
      end

      it 'installs vpnaas package' do
        should contain_package('neutron-vpnaas-agent').with(
          :ensure => params[:package_ensure],
          :name   => platform_params[:vpnaas_package_name],
        )
      end
    end

    context 'with multiple service providers' do
      let :params do
        default_params.merge(
          { :service_providers => ['provider1', 'provider2'] }
        )
      end

      it 'configures neutron_vpnaas.conf' do
        should contain_neutron_vpnaas_service_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
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
        when 'Debian'
          {
            :vpnaas_package_name => 'python-neutron-vpnaas'
          }
        when 'RedHat'
          {
            :vpnaas_package_name => 'openstack-neutron-vpnaas'
          }
        end
      end

      it_behaves_like 'neutron vpnaas service plugin'
    end
  end
end
