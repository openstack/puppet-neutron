# == Define: neutron::plugins::ml2::cisco::nexus_switch_server
#
# Defined type to configure the Cisco Nexus Switch parameters
# for servers connected to the switch for use by the ML2 Mech
# Driver for Cisco Nexus Switches.
#
# More info available here:
# http://networking-cisco.readthedocs.io
#
#
# neutron::plugins::ml2::cisco::nexus_switch_server used by
# neutron::plugins::ml2::cisco::nexus_switch
#
# === Parameters:
# [*switch_ip_address*]
# (required) The IP address for the switch.
#
# [*ports*]
# (required) The switch ports connected to this server.
#
# [*hostname*]
# (required) The hostname of a host connected to the switch.
#
define neutron::plugins::ml2::cisco::nexus_switch_server(
  $switch_ip_address,
  $ports,
  $hostname = $title,
) {

  include ::neutron::deps

  $section = "ML2_MECH_CISCO_NEXUS:${switch_ip_address}"
  neutron_plugin_ml2 {
    "${section}/${hostname}": value => $ports;
  }
}
