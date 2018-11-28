#
# Copyright (C) 2016 Matthew J. Black
#
# Author: Matthew J. Black <mjblack@gmail.com>
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
# Unit tests for neutron::services::lbaas::octavia class
#

require 'spec_helper'

describe 'neutron::services::lbaas::octavia' do
  let :default_params do
    {
      :base_url              => 'http://127.0.0.1:9876',
      :request_poll_interval => '<SERVICE DEFAULT>',
      :request_poll_timeout  => '<SERVICE DEFAULT>',
      :allocates_vip         => '<SERVICE DEFAULT>',
      :auth_url              => '<SERVICE DEFAULT>',
      :admin_user            => '<SERVICE DEFAULT>',
      :admin_tenant_name     => 'services',
      :admin_password        => '<SERVICE DEFAULT>',
      :admin_user_domain     => '<SERVICE DEFAULT>',
      :admin_project_domain  => '<SERVICE DEFAULT>',
      :auth_version          => '<SERVICE DEFAULT>',
      :endpoint_type         => '<SERVICE DEFAULT>',
      :insecure              => '<SERVICE DEFAULT>' }
  end

  shared_examples 'neutron::services::lbaas::octavia' do
    context 'with default params' do
      let :params do
        default_params
      end

      it 'configures octavia service plugin' do
        should contain_neutron_config('octavia/base_url').with_value('http://127.0.0.1:9876')
        should contain_neutron_config('octavia/request_poll_interval').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('octavia/request_poll_timeout').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('octavia/allocates_vip').with_value('<SERVICE DEFAULT>')
      end

      it 'configures octavia service authentication' do
        should contain_neutron_config('service_auth/auth_url').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_user').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_tenant_name').with_value('services')
        should contain_neutron_config('service_auth/admin_password').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_user_domain').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_project_domain').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/auth_version').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/endpoint_type').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/insecure').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when base_url is set' do
      let :params do
        default_params.merge(
          {
            :base_url              => 'http://octavia.example.org:9876',
            :request_poll_interval => '3',
            :request_poll_timeout  => '100',
            :allocates_vip         => 'false'
          }
        )
      end

      it 'configures octavia service plugin custom parameters' do
        should contain_neutron_config('octavia/base_url').with_value('http://octavia.example.org:9876')
        should contain_neutron_config('octavia/request_poll_interval').with_value('3')
        should contain_neutron_config('octavia/request_poll_timeout').with_value('100')
        should contain_neutron_config('octavia/allocates_vip').with_value('false')
      end

      it 'configures octavia service authentication' do
        should contain_neutron_config('service_auth/auth_url').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_user').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_tenant_name').with_value('services')
        should contain_neutron_config('service_auth/admin_password').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_user_domain').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/admin_project_domain').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/auth_version').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/endpoint_type').with_value('<SERVICE DEFAULT>')
        should contain_neutron_config('service_auth/insecure').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when base_url and service credentials are set' do
      let :params do
        default_params.merge(
          {
            :base_url              => 'http://octavia.example.org:9876',
            :request_poll_interval => '3',
            :request_poll_timeout  => '100',
            :allocates_vip         => 'false',
            :auth_url              => 'https://auth.openstack.cloud/v3',
            :admin_user            => 'admin',
            :admin_tenant_name     => 'service-tenant',
            :admin_password        => 'secure123',
            :admin_user_domain     => 'DefaultUsers',
            :admin_project_domain  => 'DefaultProjects',
            :auth_version          => '3',
            :endpoint_type         => 'public',
            :insecure              => 'false'
          }
        )
      end

      it 'configures octavia service plugin custom parameters' do
        should contain_neutron_config('octavia/base_url').with_value('http://octavia.example.org:9876')
        should contain_neutron_config('octavia/request_poll_interval').with_value('3')
        should contain_neutron_config('octavia/request_poll_timeout').with_value('100')
        should contain_neutron_config('octavia/allocates_vip').with_value('false')
      end

      it 'configures octavia service authentication' do
        should contain_neutron_config('service_auth/auth_url').with_value('https://auth.openstack.cloud/v3')
        should contain_neutron_config('service_auth/admin_user').with_value('admin')
        should contain_neutron_config('service_auth/admin_tenant_name').with_value('service-tenant')
        should contain_neutron_config('service_auth/admin_password').with_value('secure123')
        should contain_neutron_config('service_auth/admin_user_domain').with_value('DefaultUsers')
        should contain_neutron_config('service_auth/admin_project_domain').with_value('DefaultProjects')
        should contain_neutron_config('service_auth/auth_version').with_value('3')
        should contain_neutron_config('service_auth/endpoint_type').with_value('public')
        should contain_neutron_config('service_auth/insecure').with_value('false')
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

      it_behaves_like 'neutron::services::lbaas::octavia'
    end
  end
end
