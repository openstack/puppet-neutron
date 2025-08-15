#
# Copyright (C) 2017 Red Hat Inc.
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
# Class to serve neutron API with apache mod_wsgi in place of neutron-api service.
#
# Serving neutron API from apache is the recommended way to go for production
# because of limited performance for concurrent accesses when running eventlet.
#
# When using this class you should disable your neutron-api service.
#
# == Parameters
#
#   [*servername*]
#     The servername for the virtualhost.
#     Optional. Defaults to $facts['networking']['fqdn']
#
#   [*port*]
#     The port.
#     Optional. Defaults to 9696
#
#   [*bind_host*]
#     The host/ip address Apache will listen on.
#     Optional. Defaults to undef (listen on all ip addresses).
#
#   [*path*]
#     The prefix for the endpoint.
#     Optional. Defaults to '/'
#
#   [*ssl*]
#     Use ssl ? (boolean)
#     Optional. Defaults to false
#
#   [*workers*]
#     Number of WSGI workers to spawn.
#     Optional. Defaults to $facts['os_workers']
#
#   [*priority*]
#     The priority for the vhost.
#     Optional. Defaults to 10
#
#   [*threads*]
#     The number of threads for the vhost.
#     Optional. Defaults to 1
#
#   [*wsgi_process_display_name*]
#     Name of the WSGI process display-name.
#     Optional. Defaults to undef
#
#   [*ssl_cert*]
#   [*ssl_key*]
#   [*ssl_chain*]
#   [*ssl_ca*]
#   [*ssl_crl_path*]
#   [*ssl_crl*]
#   [*ssl_certs_dir*]
#     apache::vhost ssl parameters.
#     Optional. Default to apache::vhost 'ssl_*' defaults.
#
#   [*access_log_file*]
#     The log file name for the virtualhost.
#     Optional. Defaults to undef.
#
#   [*access_log_pipe*]
#     Specifies a pipe where Apache sends access logs for the virtualhost.
#     Optional. Defaults to undef.
#
#   [*access_log_syslog*]
#     Sends the virtualhost access log messages to syslog.
#     Optional. Defaults to undef.
#
#   [*access_log_format*]
#     The log format for the virtualhost.
#     Optional. Defaults to undef.
#
#   [*access_log_env_var*]
#     Specifies that only requests with particular
#     environment variables be logged.
#     Optional. Defaults to undef
#
#   [*error_log_file*]
#     The error log file name for the virtualhost.
#     Optional. Defaults to undef.
#
#   [*error_log_pipe*]
#     Specifies a pipe where Apache sends error logs for the virtualhost.
#     Optional. Defaults to undef.
#
#   [*error_log_syslog*]
#     Sends the virtualhost error log messages to syslog.
#     Optional. Defaults to undef.
#
#   [*custom_wsgi_process_options*]
#     Gives you the opportunity to add custom process options or to
#     overwrite the default options for the WSGI main process.
#     eg. to use a virtual python environment for the WSGI process
#     you could set it to:
#     { python-path => '/my/python/virtualenv' }
#     Optional. Defaults to {}
#
#   [*headers*]
#     Headers for the vhost.
#     Optional. Defaults to undef
#
#   [*request_headers*]
#     Modifies collected request headers in various ways.
#     Optional. Defaults to undef
#
# == Dependencies
#
#   requires Class['apache'] & Class['neutron']
#
# == Examples
#
#   include apache
#
#   class { 'neutron::wsgi::apache': }
#
class neutron::wsgi::apache (
  $servername                  = $facts['networking']['fqdn'],
  $port                        = 9696,
  $bind_host                   = undef,
  $path                        = '/',
  $ssl                         = false,
  $workers                     = $facts['os_workers'],
  $ssl_cert                    = undef,
  $ssl_key                     = undef,
  $ssl_chain                   = undef,
  $ssl_ca                      = undef,
  $ssl_crl_path                = undef,
  $ssl_crl                     = undef,
  $ssl_certs_dir               = undef,
  $wsgi_process_display_name   = undef,
  $threads                     = 1,
  $priority                    = 10,
  $access_log_file             = undef,
  $access_log_pipe             = undef,
  $access_log_syslog           = undef,
  $access_log_format           = undef,
  $access_log_env_var          = undef,
  $error_log_file              = undef,
  $error_log_pipe              = undef,
  $error_log_syslog            = undef,
  $custom_wsgi_process_options = {},
  $headers                     = undef,
  $request_headers             = undef,
) {

  include neutron::deps
  include neutron::params

  Anchor['neutron::install::end'] -> Class['apache']

  openstacklib::wsgi::apache { 'neutron_wsgi':
    bind_host                   => $bind_host,
    bind_port                   => $port,
    group                       => $neutron::params::group,
    path                        => $path,
    priority                    => $priority,
    servername                  => $servername,
    ssl                         => $ssl,
    ssl_ca                      => $ssl_ca,
    ssl_cert                    => $ssl_cert,
    ssl_certs_dir               => $ssl_certs_dir,
    ssl_chain                   => $ssl_chain,
    ssl_crl                     => $ssl_crl,
    ssl_crl_path                => $ssl_crl_path,
    ssl_key                     => $ssl_key,
    threads                     => $threads,
    user                        => $neutron::params::user,
    workers                     => $workers,
    wsgi_daemon_process         => 'neutron',
    wsgi_process_display_name   => $wsgi_process_display_name,
    wsgi_process_group          => 'neutron',
    wsgi_script_dir             => $neutron::params::neutron_wsgi_script_path,
    wsgi_script_file            => 'app',
    wsgi_script_source          => $neutron::params::neutron_wsgi_script_source,
    headers                     => $headers,
    request_headers             => $request_headers,
    custom_wsgi_process_options => $custom_wsgi_process_options,
    access_log_file             => $access_log_file,
    access_log_pipe             => $access_log_pipe,
    access_log_syslog           => $access_log_syslog,
    access_log_format           => $access_log_format,
    access_log_env_var          => $access_log_env_var,
    error_log_file              => $error_log_file,
    error_log_pipe              => $error_log_pipe,
    error_log_syslog            => $error_log_syslog,
  }
}
