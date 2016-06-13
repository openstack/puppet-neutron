# == Define: neutron::plugins::ml2::cisco::nexus_creds
#
# Defined type to configure the Cisco Nexus Switch Credentials
# for use by the ML2 Mech Driver for Cisco Nexus Switches.
#
# More info available here:
# https://wiki.openstack.org/wiki/Neutron/ML2/MechCiscoNexus
#
#
# neutron::plugins::ml2::cisco::nexus_creds used by
# neutron::plugins::ml2::cisco::nexus
#
# === Parameters:
#
# [*username*]
# (not used) The username for logging into the switch to manage it.
#
# [*password*]
# (not used) The password for logging into the switch to manage it.
#
# [*servers*]
# (not used) A hash of server names (key) mapped to the switch's
# interfaces (value).  For each host connected to a port on the
# switch, specify the hostname and the Nexus physical port/s
# (interface/s) it is connected to.  The values in the hash can
# be a comma separated list of interfaces mapped to the server.
#
# Hash Format:
#
#  {
#     <hostname> => "<interfaceID1>,<interfaceID2>,<... interfaceID_N>"
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
#        'control1' => 'ethernet:1/1',
#        'control2' => 'ethernet:1/2',
#        'compute1' => '1/3,1/4'
#      }
#
# [*ip_address*]
# (required) The IP address of the switch.
#
# [*ssh_port*]
# (not used) The SSH port to use when connecting to the switch.
#
# [*nve_src_intf*]
# (not used) Only valid if VXLAN overlay is configured and
# vxlan_global_config is set to True.
#
# The NVE source interface is a loopback interface that is configured on
# the switch with valid /32 IP address. This /32 IP address must be known
# by the transient devices in the transport network and the remote VTEPs.
# This is accomplished by advertising it through a dynamic routing protocol
# in the transport network. (NB: If no nve_src_intf is defined then a
# default setting of 0 (creates "loopback0") will be used.)
#
# Defaults to undef.
#
# [*physnet*]
# (not used) Only valid if VXLAN overlay is configured.
# The physical network name defined in the network_vlan_ranges variable
# (defined under the ml2_type_vlan section) that this switch is controlling.
# The configured 'physnet' is the physical network domain that is connected
# to this switch. The vlan ranges defined in network_vlan_ranges for a
# a physical network are allocated dynamically and are unique per physical
# network. These dynamic vlans may be reused across physical networks.
#
# Defaults to undef.
#
define neutron::plugins::ml2::cisco::nexus_creds(
  # Not used parameters
  $username,
  $password,
  $servers,
  $ssh_port,
  # Used parameters
  $ip_address,
  $nve_src_intf = undef,
  $physnet      = undef,

) {
  include ::neutron::deps

  ensure_resource('file', '/var/lib/neutron/.ssh',
    {
      ensure => directory,
      owner  => 'neutron',
      tag    => 'neutron-config-file',
    }
  )

  $check_known_hosts = "/bin/cat /var/lib/neutron/.ssh/known_hosts | /bin/grep ${ip_address}"

  # Test to make sure switch is reachable before ssh-keyscan.
  #  - ssh-keyscan timeouts fail silently so use ping to
  #    report connectivity failures.
  exec {"ping_test_${name}":
    unless  => $check_known_hosts,
    command => "/usr/bin/ping -c 1 ${ip_address}",
    user    => 'neutron'
  }

  exec {"nexus_creds_${name}":
    unless  => $check_known_hosts,
    command => "/usr/bin/ssh-keyscan -t rsa ${ip_address} >> /var/lib/neutron/.ssh/known_hosts",
    user    => 'neutron',
    require => [Exec["ping_test_${name}"], Anchor['neutron::config::end']]
  }
}
