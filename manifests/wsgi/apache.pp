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
#     Optional. Defaults to $::fqdn
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
#     Optional. Defaults to true
#
#   [*workers*]
#     Number of WSGI workers to spawn.
#     Optional. Defaults to $::os_workers
#
#   [*priority*]
#     (optional) The priority for the vhost.
#     Defaults to '10'
#
#   [*threads*]
#     (optional) The number of threads for the vhost.
#     Defaults to 1
#
#   [*wsgi_process_display_name*]
#     (optional) Name of the WSGI process display-name.
#     Defaults to undef
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
#     Optional. Defaults to false.
#
#   [*access_log_format*]
#     The log format for the virtualhost.
#     Optional. Defaults to false.
#
#   [*error_log_file*]
#     The error log file name for the virtualhost.
#     Optional. Defaults to undef.
#
# [*custom_wsgi_process_options*]
#   (optional) gives you the opportunity to add custom process options or to
#   overwrite the default options for the WSGI main process.
#   eg. to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
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
  $servername                  = $::fqdn,
  $port                        = 9696,
  $bind_host                   = undef,
  $path                        = '/',
  $ssl                         = true,
  $workers                     = $::os_workers,
  $ssl_cert                    = undef,
  $ssl_key                     = undef,
  $ssl_chain                   = undef,
  $ssl_ca                      = undef,
  $ssl_crl_path                = undef,
  $ssl_crl                     = undef,
  $ssl_certs_dir               = undef,
  $wsgi_process_display_name   = undef,
  $threads                     = 1,
  $priority                    = '10',
  $access_log_file             = false,
  $access_log_format           = false,
  $error_log_file              = undef,
  $custom_wsgi_process_options = {},
) {

  include ::neutron::deps
  include ::neutron::params
  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  # The httpd package is untagged, but needs to have ordering enforced,
  # so handle it here rather than in the deps class.
  Anchor['neutron::install::begin']
  -> Package['httpd']
  -> Anchor['neutron::install::end']

  # Configure apache during the config phase
  Anchor['neutron::config::begin']
  -> Apache::Vhost<||>
  ~> Anchor['neutron::config::end']

  # Start the service during the service phase
  Anchor['neutron::service::begin']
  -> Service['httpd']
  -> Anchor['neutron::service::end']

  # Notify the service when config changes
  Anchor['neutron::config::end']
  ~> Service['httpd']

  ::openstacklib::wsgi::apache { 'neutron_wsgi':
    bind_host                   => $bind_host,
    bind_port                   => $port,
    group                       => 'neutron',
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
    user                        => 'neutron',
    workers                     => $workers,
    wsgi_daemon_process         => 'neutron',
    wsgi_process_display_name   => $wsgi_process_display_name,
    wsgi_process_group          => 'neutron',
    wsgi_script_dir             => $::neutron::params::neutron_wsgi_script_path,
    wsgi_script_file            => 'app',
    wsgi_script_source          => $::neutron::params::neutron_wsgi_script_source,
    custom_wsgi_process_options => $custom_wsgi_process_options,
    access_log_file             => $access_log_file,
    access_log_format           => $access_log_format,
    error_log_file              => $error_log_file,
  }
}
