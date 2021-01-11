#
# DEPRECATED !
# Configure the Nexus VXLAN Type Driver
# More info available here:
# http://networking-cisco.readthedocs.io
#
# === Parameters
#
# [*vni_ranges*]
#   (required)
#   Comma-separated list of <vni_min>:<vni_max> tuples enumerating
#   ranges of VXLAN Network IDs that are available for tenant network
#   allocation.
#
# [*mcast_ranges*]
#   (required)
#   Multicast groups for the VXLAN interface. When configured, will
#   enable sending all broadcast traffic to this multicast group.
#   Comma separated list of min:max ranges of multicast IP's.
#   NOTE: must be a valid multicast IP, invalid IP's will be discarded
#   Example:
#   224.0.0.1:224.0.0.3,224.0.1.1:224.0.1.3
#

class neutron::plugins::ml2::cisco::type_nexus_vxlan (
  $vni_ranges,
  $mcast_ranges,
) {

  warning('Support for networking-cisco has been deprecated and has no effect')
}

