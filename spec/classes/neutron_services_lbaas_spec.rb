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
    { :service_providers => '<SERVICE_DEFAULT>'}
  end

  shared_examples_for 'neutron lbaas service plugin' do

    context 'with default params' do
      let :params do
        default_params
      end

      it 'should contain python-neutron-lbaas package' do
        is_expected.to contain_package('python-neutron-lbaas').with({ :ensure => 'present' })
      end

      it 'should set certificates options with service defaults' do
        is_expected.to contain_neutron_config('certificates/cert_manager_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_config('certificates/storage_path').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_neutron_config('certificates/barbican_auth').with_value('<SERVICE DEFAULT>')
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
          is_expected.to contain_neutron_config('certificates/cert_manager_type').with_value('barbican')
          is_expected.to contain_neutron_config('certificates/storage_path').with_value('/var/lib/neutron-lbaas/certificates/')
          is_expected.to contain_neutron_config('certificates/barbican_auth').with_value('barbican_acl_auth')
        end
      end
    end

    context 'with multiple service providers' do
      let :params do
        default_params.merge(
          { :service_providers => ['provider1', 'provider2'] }
        )
      end

      it 'configures neutron.conf' do
        is_expected.to contain_neutron_lbaas_service_config(
          'service_providers/service_provider'
        ).with_value(['provider1', 'provider2'])
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'neutron lbaas service plugin'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'neutron lbaas service plugin'
  end
end
