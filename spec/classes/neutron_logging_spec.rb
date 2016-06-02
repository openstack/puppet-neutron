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
      is_expected.to contain_neutron_config('DEFAULT/use_syslog').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/use_stderr').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/syslog_log_facility').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/log_dir').with(:value => '/var/log/neutron')
      is_expected.to contain_neutron_config('DEFAULT/log_file').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/watch_log_file').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_neutron_config('DEFAULT/debug').with(:value => '<SERVICE DEFAULT>')
    end
  end

  shared_examples 'basic non-default logging settings' do
    it 'configures neutron logging settins with non-default values' do
      is_expected.to contain_neutron_config('DEFAULT/use_syslog').with(:value => 'false')
      is_expected.to contain_neutron_config('DEFAULT/use_stderr').with(:value => 'false')
      is_expected.to contain_neutron_config('DEFAULT/syslog_log_facility').with(:value => 'LOG_USER')
      is_expected.to contain_neutron_config('DEFAULT/log_dir').with(:value => '/var/log')
      is_expected.to contain_neutron_config('DEFAULT/log_file').with(:value => 'neutron.log')
      is_expected.to contain_neutron_config('DEFAULT/watch_log_file').with(:value => 'true')
      is_expected.to contain_neutron_config('DEFAULT/debug').with(:value => 'true')
    end
  end

  shared_examples_for 'logging params set' do
    it 'enables logging params' do
      is_expected.to contain_neutron_config('DEFAULT/logging_context_format_string').with_value(
        '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s')

      is_expected.to contain_neutron_config('DEFAULT/logging_default_format_string').with_value(
        '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s')

      is_expected.to contain_neutron_config('DEFAULT/logging_user_identity_format').with_value(
        '%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s')

      is_expected.to contain_neutron_config('DEFAULT/logging_debug_format_suffix').with_value(
        '%(funcName)s %(pathname)s:%(lineno)d')

      is_expected.to contain_neutron_config('DEFAULT/logging_exception_prefix').with_value(
       '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s')

      is_expected.to contain_neutron_config('DEFAULT/log_config_append').with_value(
        '/etc/neutron/logging.conf')
      is_expected.to contain_neutron_config('DEFAULT/publish_errors').with_value(
        true)

      is_expected.to contain_neutron_config('DEFAULT/default_log_levels').with_value(
        'amqp=WARN,amqplib=WARN,boto=WARN,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,sqlalchemy=WARN,suds=INFO')

      is_expected.to contain_neutron_config('DEFAULT/fatal_deprecations').with_value(
        true)

      is_expected.to contain_neutron_config('DEFAULT/instance_format').with_value(
        '[instance: %(uuid)s] ')

      is_expected.to contain_neutron_config('DEFAULT/instance_uuid_format').with_value(
        '[instance: %(uuid)s] ')

      is_expected.to contain_neutron_config('DEFAULT/log_date_format').with_value(
        '%Y-%m-%d %H:%M:%S')
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
