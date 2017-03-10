require 'spec_helper'

describe 'neutron::logging' do

  let :params do
    {
    }
  end

  let :log_params do
    {
      :logging_context_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s',
      :logging_default_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s',
      :logging_debug_format_suffix => '%(funcName)s %(pathname)s:%(lineno)d',
      :logging_exception_prefix => '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s',
      :logging_user_identity_format => '%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s',
      :log_config_append => '/etc/neutron/logging.conf',
      :publish_errors => true,
      :default_log_levels => {
        'amqp' => 'WARN', 'amqplib' => 'WARN', 'boto' => 'WARN',
        'sqlalchemy' => 'WARN', 'suds' => 'INFO', 'iso8601' => 'WARN',
        'requests.packages.urllib3.connectionpool' => 'WARN' },
     :fatal_deprecations => true,
     :instance_format => '[instance: %(uuid)s] ',
     :instance_uuid_format => '[instance: %(uuid)s] ',
     :log_date_format => '%Y-%m-%d %H:%M:%S',
     :use_syslog => false,
     :use_stderr => false,
     :syslog_log_facility => 'LOG_USER',
     :log_dir => '/var/log',
     :log_file => 'neutron.log',
     :watch_log_file => true,
     :debug => true,
    }
  end

  shared_examples_for 'neutron-logging' do

    context 'with basic logging options and default settings' do
      it_configures  'basic default logging settings'
    end

    context 'with basic logging options and non-default settings' do
      before { params.merge!( log_params ) }
      it_configures 'basic non-default logging settings'
    end

    context 'with extended logging options' do
      before { params.merge!( log_params ) }
      it_configures 'logging params set'
    end

  end

  shared_examples 'basic default logging settings' do
    it 'configures neutron logging settins with default values' do
      is_expected.to contain_oslo__log('neutron_config').with(
        :use_syslog          => '<SERVICE DEFAULT>',
        :use_stderr          => '<SERVICE DEFAULT>',
        :syslog_log_facility => '<SERVICE DEFAULT>',
        :log_dir             => '/var/log/neutron',
        :log_file            => '<SERVICE DEFAULT>',
        :watch_log_file      => '<SERVICE DEFAULT>',
        :debug               => '<SERVICE DEFAULT>',
      )
    end
  end

  shared_examples 'basic non-default logging settings' do
    it 'configures neutron logging settins with non-default values' do
      is_expected.to contain_oslo__log('neutron_config').with(
        :use_syslog          => false,
        :use_stderr          => false,
        :syslog_log_facility => 'LOG_USER',
        :log_dir             => '/var/log',
        :log_file            => 'neutron.log',
        :watch_log_file      => true,
        :debug               => true,
      )
    end
  end

  shared_examples_for 'logging params set' do
    it 'enables logging params' do
      is_expected.to contain_oslo__log('neutron_config').with(
        :logging_context_format_string =>
          '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s',
        :logging_default_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s',
        :logging_debug_format_suffix   => '%(funcName)s %(pathname)s:%(lineno)d',
        :logging_exception_prefix      => '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s',
        :logging_user_identity_format  => '%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s',
        :log_config_append             => '/etc/neutron/logging.conf',
        :publish_errors                => true,
        :default_log_levels            => {
          'amqp' => 'WARN', 'amqplib' => 'WARN', 'boto' => 'WARN',
          'sqlalchemy' => 'WARN', 'suds' => 'INFO', 'iso8601' => 'WARN',
          'requests.packages.urllib3.connectionpool' => 'WARN' },
        :fatal_deprecations             => true,
        :instance_format                => '[instance: %(uuid)s] ',
        :instance_uuid_format           => '[instance: %(uuid)s] ',
        :log_date_format                => '%Y-%m-%d %H:%M:%S',
      )
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'neutron-logging'
    end
  end

end
