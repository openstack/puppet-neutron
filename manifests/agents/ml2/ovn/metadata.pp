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
# == Class: neutron::agents:ml2::ovn::metadata
#
# Setups metadata extension options for ovn agent
#
# === Parameters
#
# [*shared_secret*]
#   (required) Shared secret to validate proxies Neutron metadata requests.
#
# [*auth_ca_cert*]
#   (optionall) CA cert to check against with for ssl keystone.
#   Defaults to $facts['os_service_default']
#
# [*nova_client_cert*]
#   (optionall) Client certificate for nova metadata api server.
#   Defaults to $facts['os_service_default']
#
# [*nova_client_priv_key*]
#   (optionall) Private key of client certificate.
#   Defaults to $facts['os_service_default']
#
# [*metadata_host*]
#   (optionall) The hostname of the metadata service.
#   Defaults to $facts['os_service_default']
#
# [*metadata_port*]
#   (optionall) The TCP port of the metadata service.
#   Defaults to $facts['os_service_default']
#
# [*metadata_protocol*]
#   (optionall) The protocol to use for requests to Nova metadata server.
#   Defaults to $facts['os_service_default']
#
# [*metadata_workers*]
#   (optional) Number of separate worker processes to spawn.  Greater than 0
#   launches that number of child processes as workers.  The parent process
#   manages them.
#   Defaults to $facts['os_service_default']
#
# [*metadata_backlog*]
#   (optional) Number of backlog requests to configure the metadata server
#   socket with.
#   Defaults to $facts['os_service_default']
#
# [*metadata_insecure*]
#   (optional) Allow to perform insecure SSL (https) requests to nova metadata.
#   Defaults to $facts['os_service_default']
#
class neutron::agents::ml2::ovn::metadata (
  $shared_secret,
  $auth_ca_cert         = $facts['os_service_default'],
  $nova_client_cert     = $facts['os_service_default'],
  $nova_client_priv_key = $facts['os_service_default'],
  $metadata_host        = $facts['os_service_default'],
  $metadata_port        = $facts['os_service_default'],
  $metadata_protocol    = $facts['os_service_default'],
  $metadata_workers     = $facts['os_service_default'],
  $metadata_backlog     = $facts['os_service_default'],
  $metadata_insecure    = $facts['os_service_default'],
) {
  include neutron::deps

  neutron_agent_ovn {
    'DEFAULT/auth_ca_cert':                 value => $auth_ca_cert;
    'DEFAULT/nova_client_cert':             value => $nova_client_cert;
    'DEFAULT/nova_client_priv_key':         value => $nova_client_priv_key;
    'DEFAULT/nova_metadata_host':           value => $metadata_host;
    'DEFAULT/nova_metadata_port':           value => $metadata_port;
    'DEFAULT/nova_metadata_protocol':       value => $metadata_protocol;
    'DEFAULT/metadata_proxy_shared_secret': value => $shared_secret, secret => true;
    'DEFAULT/metadata_workers':             value => $metadata_workers;
    'DEFAULT/metadata_backlog':             value => $metadata_backlog;
    'DEFAULT/nova_metadata_insecure':       value => $metadata_insecure;
  }
}
