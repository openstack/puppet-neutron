# Defined type for networking-ansible configuration for a host/switch
#
# == Class: neutron::plugins::ml2::networking_ansible_host
#
# === Parameters
#
# [*ansible_network_os*]
#   (Required) Operating system of the network device
#
# [*ansible_host*]
#   (Required) IP Address of the network device
#
# [*ansible_user*]
#   (Required) Username to connect to the network device
#
# [*ansible_ssh_pass*]
#   (Optional) SSH password to connect to the network device
#   This or ansible_ssh_private_key_file should be provided
#   Defaults to $::os_service_default
#
# [*ansible_ssh_private_key_file*]
#   (Optional) SSH private key to connect to the network device
#   This or ansible_ssh_pass should be provided
#   Defaults to $::os_service_default
#
# [*hostname*]
#   (Optional) The hostname of a host connected to the switch.
#   Defaults to $title
#
# [*mac*]
#   (Optional) Chassis MAC ID of the network device. Used to map lldp provided
#   value to the hostname when using ironic introspection.
#   Defaults to $::os_service_default
#
# [*manage_vlans*]
#   Should networking-ansible create and delete VLANs on the device.
#   Defaults to $::os_service_default
#
define neutron::plugins::ml2::networking_ansible_host(
  $ansible_network_os,
  $ansible_host,
  $ansible_user,
  $ansible_ssh_pass             = $::os_service_default,
  $ansible_ssh_private_key_file = $::os_service_default,
  $mac                          = $::os_service_default,
  $hostname                     = $title,
  $manage_vlans                 = $::os_service_default,
) {

  include neutron::deps
  require neutron::plugins::ml2

  if ((is_service_default($ansible_ssh_pass) and is_service_default($ansible_ssh_private_key_file)) or
      (!is_service_default($ansible_ssh_pass) and !is_service_default($ansible_ssh_private_key_file))) {
    fail('One of ansible_ssh_pass OR ansible_ssh_private_key_file should be set')
  }

  $section = "ansible:${hostname}"
  neutron_plugin_ml2 {
    "${section}/ansible_network_os":           value => $ansible_network_os;
    "${section}/ansible_host":                 value => $ansible_host;
    "${section}/ansible_user":                 value => $ansible_user;
    "${section}/ansible_ssh_pass":             value => $ansible_ssh_pass, secret => true;
    "${section}/ansible_ssh_private_key_file": value => $ansible_ssh_private_key_file;
    "${section}/mac":                          value => $mac;
    "${section}/manage_vlans":                 value => $manage_vlans;
  }
}
