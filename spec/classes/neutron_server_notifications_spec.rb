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
# Unit tests for neutron::server::notifications class
#

require 'spec_helper'

describe 'neutron::server::notifications' do

    let :params do
        {
            :notify_nova_on_port_status_changes => true,
            :notify_nova_on_port_data_changes   => true,
            :auth_type                          => 'password',
            :username                           => 'nova',
            :password                           => 'secrete',
            :tenant_name                        => 'services',
            :project_domain_id                  => 'default',
            :project_domain_name                => 'Default',
            :project_name                       => 'services',
            :user_domain_id                     => 'default',
            :user_domain_name                   => 'Default',
            :auth_url                           => 'http://127.0.0.1:35357',
        }
    end

    let :test_facts do
      { :operatingsystem           => 'default',
        :operatingsystemrelease    => 'default'
      }
    end

    shared_examples_for 'neutron server notifications' do

        it 'configure neutron.conf' do
            is_expected.to contain_neutron_config('DEFAULT/notify_nova_on_port_status_changes').with_value(true)
            is_expected.to contain_neutron_config('DEFAULT/notify_nova_on_port_data_changes').with_value(true)
            is_expected.to contain_neutron_config('DEFAULT/send_events_interval').with_value('<SERVICE DEFAULT>')
            is_expected.to contain_neutron_config('nova/auth_type').with_value('password')
            is_expected.to contain_neutron_config('nova/auth_url').with_value('http://127.0.0.1:35357')
            is_expected.to contain_neutron_config('nova/username').with_value('nova')
            is_expected.to contain_neutron_config('nova/password').with_value('secrete')
            is_expected.to contain_neutron_config('nova/password').with_secret( true )
            is_expected.to contain_neutron_config('nova/tenant_name').with_value('services')
            is_expected.to contain_neutron_config('nova/region_name').with_value('<SERVICE DEFAULT>')
            is_expected.to contain_neutron_config('nova/project_domain_id').with_value('default')
            is_expected.to contain_neutron_config('nova/project_domain_name').with_value('Default')
            is_expected.to contain_neutron_config('nova/user_domain_id').with_value('default')
            is_expected.to contain_neutron_config('nova/user_domain_name').with_value('Default')
            is_expected.to contain_neutron_config('nova/endpoint_type').with_value('<SERVICE DEFAULT>')
        end

        context 'when overriding parameters' do
            before :each do
                params.merge!(
                    :notify_nova_on_port_status_changes => false,
                    :notify_nova_on_port_data_changes   => false,
                    :send_events_interval               => '10',
                    :auth_url                           => 'http://keystone:35357/v2.0',
                    :auth_type                          => 'v2password',
                    :username                           => 'joe',
                    :region_name                        => 'MyRegion',
                    :tenant_id                          => 'UUID2',
                    :project_domain_id                  => 'default_1',
                    :project_domain_name                => 'Default_2',
                    :user_domain_id                     => 'default_3',
                    :user_domain_name                   => 'Default_4',
                    :endpoint_type                      => 'internal'
                )
            end
            it 'should configure neutron server with overrided parameters' do
                is_expected.to contain_neutron_config('DEFAULT/notify_nova_on_port_status_changes').with_value(false)
                is_expected.to contain_neutron_config('DEFAULT/notify_nova_on_port_data_changes').with_value(false)
                is_expected.to contain_neutron_config('DEFAULT/send_events_interval').with_value('10')
                is_expected.to contain_neutron_config('nova/auth_url').with_value('http://keystone:35357/v2.0')
                is_expected.to contain_neutron_config('nova/auth_type').with_value('v2password')
                is_expected.to contain_neutron_config('nova/username').with_value('joe')
                is_expected.to contain_neutron_config('nova/password').with_value('secrete')
                is_expected.to contain_neutron_config('nova/password').with_secret( true )
                is_expected.to contain_neutron_config('nova/region_name').with_value('MyRegion')
                is_expected.to contain_neutron_config('nova/tenant_id').with_value('UUID2')
                is_expected.to contain_neutron_config('nova/project_domain_id').with_value('default_1')
                is_expected.to contain_neutron_config('nova/project_domain_name').with_value('Default_2')
                is_expected.to contain_neutron_config('nova/user_domain_id').with_value('default_3')
                is_expected.to contain_neutron_config('nova/user_domain_name').with_value('Default_4')
                is_expected.to contain_neutron_config('nova/endpoint_type').with_value('internal')
            end
        end

        context 'when no tenant_id and tenant_name specified' do
            before :each do
                params.merge!({ :tenant_name => false })
            end

            it_raises 'a Puppet::Error', /You must provide either tenant_name or tenant_id./
        end

    end

    context 'on Debian platforms' do
        let :facts do
            @default_facts.merge(test_facts.merge({
               :osfamily => 'Debian'
            }))
        end

        let :platform_params do
            {}
        end

        it_configures 'neutron server notifications'
    end

    context 'on RedHat platforms' do
        let :facts do
            @default_facts.merge(test_facts.merge({
               :osfamily               => 'RedHat',
               :operatingsystemrelease => '7'
            }))
        end

        let :platform_params do
            {}
        end

        it_configures 'neutron server notifications'
    end

end
