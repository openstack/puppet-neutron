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
# == Class: neutron::agents:ovn_metadata::metadata_rate_limiting
#
# Setups metadata ratelimit options for ovn metadata agent
#
# === Parameters
#
# [*rate_limit_enabled*]
#  (Optional) Enable rate limiting on the metadata API.
#  Defaults to $facts['os_service_default'].
#
# [*ip_versions*]
#  (Optional) List of the metadata address IP versions for which rate limiting
#  will be enabled.
#  Defaults to $facts['os_service_default'].
#
# [*base_window_duration*]
#  (Optional) Duration (seconds) of the base window on the metadata API.
#  Defaults to $facts['os_service_default'].
#
# [*base_query_rate_limit*]
#  (Optional) Max number of queries to accept during the base window.
#  Defaults to $facts['os_service_default'].
#
# [*burst_window_duration*]
#  (Optional) Duration (seconds) of the burst window on the metadata API.
#  Defaults to $facts['os_service_default'].
#
# [*burst_query_rate_limit*]
#  (Optional) Max number of queries to accept during the burst window.
#  Defaults to $facts['os_service_default'].
#
class neutron::agents::ovn_metadata::metadata_rate_limiting (
  $rate_limit_enabled     = $facts['os_service_default'],
  $ip_versions            = $facts['os_service_default'],
  $base_window_duration   = $facts['os_service_default'],
  $base_query_rate_limit  = $facts['os_service_default'],
  $burst_window_duration  = $facts['os_service_default'],
  $burst_query_rate_limit = $facts['os_service_default'],
) {
  include neutron::deps

  ovn_metadata_agent_config {
    'metadata_rate_limiting/rate_limit_enabled':     value => $rate_limit_enabled;
    'metadata_rate_limiting/ip_versions':            value => join(any2array($ip_versions), ',');
    'metadata_rate_limiting/base_window_duration':   value => $base_window_duration;
    'metadata_rate_limiting/base_query_rate_limit':  value => $base_query_rate_limit;
    'metadata_rate_limiting/burst_window_duration':  value => $burst_window_duration;
    'metadata_rate_limiting/burst_query_rate_limit': value => $burst_query_rate_limit;
  }
}
