#
# Copyright (C) 2014 Red Hat Inc.
#
# Author: Martin Magr <mmagr@redhat.com>
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
# Unit tests for neutron::services::lbaas class
#

require 'spec_helper'

describe 'neutron::services::lbaas' do
  let :default_params do
    {}
  end

  shared_examples 'neutron lbaas service plugin' do

    context 'with default params' do
      let :params do
        default_params
      end

      it 'should contain python-neutron-lbaas package' do
        should contain_package(platform_params[:lbaas_package_name]).with({ :ensure => 'present' })
      end

      it 'should set certificates options with service defaults' do
        should contain_neutron_config('certificates/cert_manager_type').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('certificates/storage_path').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('certificates/barbican_auth').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with certificate manager options' do
      before :each do
        params.merge!(
          { :cert_manager_type => 'barbican',
            :cert_storage_path => '/var/lib/neutron-lbaas/certificates/',
            :barbican_auth     => 'barbican_acl_auth'
          }
        )

        it 'should configure certificates section' do
          should contain_neutron_config('certificates/cert_manager_type').with_value('barbican')
          should contain_neutron_config('certificates/storage_path').with_value('/var/lib/neutron-lbaas/certificates/')
          should contain_neutron_config('certificates/barbican_auth').with_value('barbican_acl_auth')
        end
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
            :lbaas_package_name => 'python3-neutron-lbaas'
          }
        when 'RedHat'
          {
            :lbaas_package_name => 'python-neutron-lbaas'
          }
        end
      end

      it_behaves_like 'neutron lbaas service plugin'
    end
  end
end
