# == Define: neutron::plugins::ml2::cisco::nexus_creds
#
# Defined type to configure the Cisco Nexus Switch Credentials
# for use by the ML2 Mech Driver for Cisco Nexus Switches.
#
# More info available here:
# http://networking-cisco.readthedocs.io
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
# [*vpc_pool*]
# (not used) Required for Baremetal deployments and Port-Channel creation
# is needed.  This defines the pool of port-channel ids which are
# available for port-channel creation.
#
# Defaults to undef.
#
# [*intfcfg_portchannel*]
# (not used) For use with Baremetal deployments and custom port-channel
# configuration is required during port-channel creation.
#
# Defaults to undef.
#
# [*https_verify*]
# (not used) Set to True when certification authority (CA) file is in
# the Operating System repository or is a locally defined file whose
# name is provided in https_local_certificate.  Set to False
# to skip https certification checking thus making the connection
# insecure.  Getting a certificate and setting https_verify to True
# is strongly advised for production to prevent man-in-the-middle
# attacks.  The default is True for a secure connection.
#
# Defaults to undef.
#
# [*https_local_certificate*]
# (not used) Configure a local certificate file to present in https
# requests.  For experimental purpose when an official certificate
# from a Trusted Certificate Authority is not yet available.
#
# Defaults to undef.
#


define neutron::plugins::ml2::cisco::nexus_creds(
  # Not used parameters
  $username,
  $password,
  $servers,
  # Used parameters
  $ip_address,
  $nve_src_intf = undef,
  $physnet      = undef,
  $vpc_pool     = undef,
  $intfcfg_portchannel = undef,
  $https_verify = undef,
  $https_local_certificate = undef,

) {
  include neutron::deps

  ensure_resource('file', '/var/lib/neutron/.ssh',
    {
      ensure => directory,
      owner  => 'neutron',
      tag    => 'neutron-config-file',
    }
  )
}
