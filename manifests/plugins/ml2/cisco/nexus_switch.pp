# == Define: neutron::plugins::ml2::cisco::nexus_switch
#
# Defined type to configure the Cisco Nexus Switch parameters
# for use by the ML2 Mech Driver for Cisco Nexus Switches.
#
# More info available here:
# https://wiki.openstack.org/wiki/Neutron/ML2/MechCiscoNexus
#
#
# neutron::plugins::ml2::cisco::nexus_switch used by
# neutron::plugins::ml2::cisco::nexus
#
# === Parameters:
# [*username*]
# (required) The username for logging into the switch to manage it.
#
# [*password*]
# (required) The password for logging into the switch to manage it.
#
# [*ip_address*]
# (required) The IP address of the switch.
#
# [*ssh_port*]
# (required) The SSH port to use when connecting to the switch.
#
# [*servers*]
# (required) A hash of server names (key) mapped to the switch's
# interfaces (value).  For each host connected to a port on the
# switch, specify the hostname and the Nexus physical port/s
# (interface/s) it is connected to.  The values in the hash can
# be a comma separated list of interfaces mapped to the server.
#
# Hash Format:
#
#  {
#     <hostname1> => {"ports" => "<interfaceID1>,<interfaceID2>, ..."},
#     <hostname2> => {"ports" => "<interfaceID1>,<interfaceID2>, ..."},
#  }
#
# Interface ID format options:
#  "<intf_type>:<position>"
#     Valid intf_type's are 'ethernet' and 'port-channel'.
#     The default setting for <intf_type:> is 'ethernet' and need not be
#     added to this setting.
#
# Example:
#      {
#        'control1' => {"ports" => 'ethernet:1/1'},
#        'control2' => {"ports" => 'ethernet:1/2'},
#        'compute1' => {"ports" => '1/3,1/4'}
#      }
#
# [*switchname*]
# (required) An identifier for the switch--ie. hostname or IP
# address of the switch.
#
# [*nve_src_intf*]
# (optional) Only valid if VXLAN overlay is configured and
# vxlan_global_config is set to True.
#
# The NVE source interface is a loopback interface that is configured on
# the switch with valid /32 IP address. This /32 IP address must be known
# by the transient devices in the transport network and the remote VTEPs.
# This is accomplished by advertising it through a dynamic routing protocol
# in the transport network. (NB: If no nve_src_intf is defined then a
# default setting of 0 (creates "loopback0") will be used.)
#
# Defaults to $::os_service_default.
#
# [*physnet*]
# (optional) Only valid if VXLAN overlay is configured.
# The physical network name defined in the network_vlan_ranges variable
# (defined under the ml2_type_vlan section) that this switch is controlling.
# The configured 'physnet' is the physical network domain that is connected
# to this switch. The vlan ranges defined in network_vlan_ranges for a
# a physical network are allocated dynamically and are unique per physical
# network. These dynamic vlans may be reused across physical networks.
#
# Defaults to $::os_service_default.
#
define neutron::plugins::ml2::cisco::nexus_switch(
  $username,
  $password,
  $ip_address,
  $ssh_port,
  $servers,
  $switchname   = $title,
  $nve_src_intf = $::os_service_default,
  $physnet      = $::os_service_default
) {

  include ::neutron::deps

  $section = "ML2_MECH_CISCO_NEXUS:${ip_address}"
  neutron_plugin_ml2 {
    "${section}/username":       value => $username;
    "${section}/password":       value => $password;
    "${section}/ssh_port":       value => $ssh_port;
    "${section}/nve_src_intf":   value => $nve_src_intf;
    "${section}/physnet":        value => $physnet;
  }

  $server_defaults = {
    'switch_ip_address' => $ip_address
  }
  create_resources(neutron::plugins::ml2::cisco::nexus_switch_server,
    $servers, $server_defaults)
}
