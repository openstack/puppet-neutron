#
# == Class: neutron::plugins::ml2::mellanox::mlnx_sdn_assist
#
# DEPRECATED !
# Install the OpenDaylight and generate config file
# from parameters in the other classes.
#
# === Parameters
#
# [*sdn_token*]
# (optional) The Mellanox controller token
# Defaults to $facts['os_service_default']
# Example: 'abcdef'
#
# [*sdn_url*]
# (optional) The Mellanox controller neutron URL
# Defaults to $facts['os_service_default']
# Example: 'http://127.0.0.1/ufmRestV3/'
#
# [*sdn_domain*]
# (optional) The Mellanox controller domain
# Defaults to $facts['os_service_default']
# Example: 'cloudx'
#
# [*sync_enabled*]
# (optional) Whether synchronising state to an
# SDN provider is enabled.
# Defaults to true
#
# [*bind_normal_ports*]
# (optional) Allow the binding of normal ports for ports
# associated with a physnet from bind_normal_ports_physnets
# Defaults to false
#
# [*bind_normal_ports_physnets*]
# (optional) A list of physnets in which binding of normal
# ports is allowed. This option is used in  conjunction
# with bind_normal_ports.
# The list must be a subset of physical_networks
# Defaults to []
#
class neutron::plugins::ml2::mellanox::mlnx_sdn_assist (
  $sdn_token                  = $facts['os_service_default'],
  $sdn_url                    = $facts['os_service_default'],
  $sdn_domain                 = $facts['os_service_default'],
  $sync_enabled               = true,
  $bind_normal_ports          = false,
  $bind_normal_ports_physnets = [],
) {
  warning('Support for networking-mlnx has been deprecated')

  include neutron::deps
  require neutron::plugins::ml2

  neutron_plugin_ml2 {
    'sdn/token':                      value => $sdn_token, secret => true;
    'sdn/url':                        value => $sdn_url;
    'sdn/domain':                     value => $sdn_domain;
    'sdn/sync_enabled':               value => $sync_enabled;
    'sdn/bind_normal_ports':          value => $bind_normal_ports;
    'sdn/bind_normal_ports_physnets': value => $bind_normal_ports_physnets;
  }
}
