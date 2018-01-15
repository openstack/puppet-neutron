# == Class: neutron::logging
#
# Neutron logging configuration
#
# === Parameters:
#
# [*debug*]
#   (optional) Print debug messages in the logs
#   Defaults to $::os_service_default
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to $::os_service_default
#
# [*use_json*]
#   (optional) Use json for logging
#   Defaults to $::os_service_default
#
# [*use_journal*]
#   (optional) Use journal for logging
#   Defaults to $::os_service_default
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to $::os_service_default
#
# [*log_file*]
#   (optional) Where to log
#   Defaults to $::os_service_default
#
# [*log_dir*]
#   (optional) Directory where logs should be stored
#   If set to $::os_service_default, it will not log to any directory
#   Defaults to /var/log/neutron
#
# [*log_config_append*]
#   The name of an additional logging configuration file.
#   Defaults to $::os_service_default
#   See https://docs.python.org/2/howto/logging.html
#
# [*log_date_format*]
#   (Optional) Format string for %%(asctime)s in log records.
#   Defaults to $::os_service_default
#   Example: 'Y-%m-%d %H:%M:%S'
#
# [*watch_log_file*]
#   (Optional) Uses logging handler designed to watch file system (boolean value).
#   Defaults to $::os_service_default
#
# [*syslog_log_facility*]
#   (Optional) Syslog facility to receive log lines.
#   This option is ignored if log_config_append is set.
#   Defaults to $::os_service_default
#
# [*logging_context_format_string*]
#   (Optional) Format string to use for log messages with context.
#   Defaults to $::os_service_default
#   Example: '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s \
#             [%(request_id)s %(user_identity)s] %(instance)s%(message)s'
#
# [*logging_default_format_string*]
#   (Optional) Format string to use for log messages when context is undefined.
#   Defaults to $::os_service_default
#   Example:  '%(asctime)s.%(msecs)03d %(process)d %(levelname)s \
#              %(name)s [-] %(instance)s%(message)s'
#
# [*logging_debug_format_suffix*]
#   (Optional) Additional data to append to log message when logging level for the message is DEBUG'
#   Defaults to $::os_service_default
#   Example: '%(funcName)s %(pathname)s:%(lineno)d'
#
# [*logging_exception_prefix*]
#   (Optional) Prefix each line of exception output with this format.
#   Defaults to $::os_service_default
#   Example: '%(asctime)s.%(msecs)03d %(process)d ERROR %(name)s %(instance)s'
#
# [*logging_user_identity_format*]
#   (Optional) Defines the format string for %(user_identity)s that is used in logging_context_format_string.
#   Defaults to $::os_service_default
#   Example: '%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s'
#
# [*default_log_levels*]
#   (Optional) Hash of logger (keys) and level (values) pairs.
#   Defaults to $::os_service_default
#   Example:
#     { 'amqp' => 'WARN', 'amqplib' => 'WARN', 'boto' => 'WARN',
#       'sqlalchemy' => 'WARN', 'suds' => 'INFO', 'iso8601' => 'WARN',
#       'requests.packages.urllib3.connectionpool' => 'WARN' }
#
# [*publish_errors*]
#   (Optional) Enables or disables publication of error events (boolean value).
#   Defaults to $::os_service_default
#
# [*instance_format*]
#   (Optional) The format for an instance that is passed with the log message.
#   Defaults to $::os_service_default
#   Example: '[instance: %(uuid)s] '
#
# [*instance_uuid_format*]
#   (Optional) The format for an instance UUID that is passed with the log message.
#   Defaults to $::os_service_default
#   Example: '[instance: %(uuid)s] '
#
# [*fatal_deprecations*]
#   (Optional) Enables or disables fatal status of deprecations (boolean value).
#   Defaults to $::os_service_default
#
class neutron::logging (
  $debug                         = $::os_service_default,
  $use_syslog                    = $::os_service_default,
  $use_json                      = $::os_service_default,
  $use_journal                   = $::os_service_default,
  $use_stderr                    = $::os_service_default,
  $log_file                      = $::os_service_default,
  $log_dir                       = '/var/log/neutron',
  $log_config_append             = $::os_service_default,
  $log_date_format               = $::os_service_default,
  $watch_log_file                = $::os_service_default,
  $syslog_log_facility           = $::os_service_default,
  $logging_context_format_string = $::os_service_default,
  $logging_default_format_string = $::os_service_default,
  $logging_debug_format_suffix   = $::os_service_default,
  $logging_exception_prefix      = $::os_service_default,
  $logging_user_identity_format  = $::os_service_default,
  $default_log_levels            = $::os_service_default,
  $publish_errors                = $::os_service_default,
  $instance_format               = $::os_service_default,
  $instance_uuid_format          = $::os_service_default,
  $fatal_deprecations            = $::os_service_default,
) {

  include ::neutron::deps

  $debug_real = pick($::neutron::debug,$debug)
  $use_syslog_real = pick($::neutron::use_syslog,$use_syslog)
  $use_stderr_real = pick($::neutron::use_stderr,$use_stderr)
  $log_file_real = pick($::neutron::log_file,$log_file)
  if $log_dir != '' {
    $log_dir_real = pick($::neutron::log_dir,$log_dir)
  } else {
    $log_dir_real = $log_dir
  }

  oslo::log { 'neutron_config':
    debug                         => $debug_real,
    use_stderr                    => $use_stderr_real,
    use_syslog                    => $use_syslog_real,
    use_json                      => $use_json,
    use_journal                   => $use_journal,
    syslog_log_facility           => $syslog_log_facility,
    log_file                      => $log_file_real,
    log_dir                       => $log_dir_real,
    log_config_append             => $log_config_append,
    log_date_format               => $log_date_format,
    watch_log_file                => $watch_log_file,
    logging_context_format_string => $logging_context_format_string,
    logging_default_format_string => $logging_default_format_string,
    logging_debug_format_suffix   => $logging_debug_format_suffix,
    logging_exception_prefix      => $logging_exception_prefix,
    logging_user_identity_format  => $logging_user_identity_format,
    default_log_levels            => $default_log_levels,
    publish_errors                => $publish_errors,
    instance_format               => $instance_format,
    instance_uuid_format          => $instance_uuid_format,
    fatal_deprecations            => $fatal_deprecations,
  }

}
