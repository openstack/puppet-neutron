#
# Configure the Fujitsu neutron ML2 plugin for FOS
#
# === Parameters
#
# [*fossw_ips*]
# (required) The List of IP address of all fos switches.
# Example: 192.168.0.1,192.168.0.2
#
# NOTE: The following parameters will be shared by all fos switches.
# [*username*]
# (optional) The username of the fos switches.
# Example: username
#
# [*password*]
# (optional) The password of the fos switches.
# Example: password
#
# [*port*]
# (optional) The port number used for SSH connection.
# Example: 22
# Defaults to 22
#
# [*timeout*]
# (optional) The timeout os SSH connection.
# Example: 30
# Defaults to 30
#
# [*udp_dest_port*]
# (optional) The port number of VXLAN UDP destination on the fos switches.
# All VXLANs on the switches use this UDP port as the UDP destination port in
# the UDP header when encapsulating.
# Example: 4789
# Defaults to 4789
#
# [*ovsdb_vlanid_range_min*]
# (optional) The minimum VLAN ID in the range that is used for binding VNI and 
# physical port. The range of 78 VLAN IDs (starts from this value) will be
# reserved. Default is 2 (VLAN ID from 2 to 79 will be reserved).
# NOTE: DO NOT include these VLAN IDs into "network_vlan_ranges" in ml2_conf.ini.
# Example: 2
# Defaults to 2
#
# [*ovsdb_port*]
# (optional) The port number which OVSDB server on the fos switches listen.
# Example: 6640
# Defaults to 6640
#
class neutron::plugins::ml2::fujitsu::fossw (
  $fossw_ips,
  $username,
  $password,
  $port                   = 22,
  $timeout                = 30,
  $udp_dest_port          = 4789,
  $ovsdb_vlanid_range_min = 2,
  $ovsdb_port             = 6640,
)
{
  require ::neutron::plugins::ml2

  neutron_plugin_ml2 {
    'fujitsu_fossw/fossw_ips'              : value => join(any2array($fossw_ips), ',');
    'fujitsu_fossw/username'               : value => $username;
    'fujitsu_fossw/password'               : value => $password, secret => true;
    'fujitsu_fossw/port'                   : value => $port;
    'fujitsu_fossw/timeout'                : value => $timeout;
    'fujitsu_fossw/udp_dest_port'          : value => $udp_dest_port;
    'fujitsu_fossw/ovsdb_vlanid_range_min' : value => $ovsdb_vlanid_range_min;
    'fujitsu_fossw/ovsdb_port'             : value => $ovsdb_port;
  }
}
