# Defined type for networking-ansible configuration for a host/switch
#
# == Class: neutron::plugins::ml2::networking_ansible_host
#
# === Parameters
#
# [*ansible_network_os*]
#   (required) Operating system of the network device
#
# [*ansible_host*]
#   (required) IP Address of the network device
#
# [*ansible_user*]
#   (required) Username to connect to the network device
#
# [*ansible_ssh_pass*]
#   (required) SSH password to connect to the network device
#
# [*hostname*]
# (required) The hostname of a host connected to the switch.
#
# [*manage_vlans*]
# Should networking-ansible create and delete VLANs on the device.
#
define neutron::plugins::ml2::networking_ansible_host(
  $ansible_network_os,
  $ansible_host,
  $ansible_user,
  $ansible_ssh_pass,
  $hostname     = $title,
  $manage_vlans = undef,
  ) {
  include ::neutron::deps
  require ::neutron::plugins::ml2

  $section = "ansible:${hostname}"
  neutron_plugin_ml2 {
    "${section}/ansible_network_os":   value => $ansible_network_os;
    "${section}/ansible_host":         value => $ansible_host;
    "${section}/ansible_user":         value => $ansible_user;
    "${section}/ansible_ssh_pass":     value => $ansible_ssh_pass, secret => true;
    "${section}/manage_vlans":         value => $manage_vlans;
  }
}
