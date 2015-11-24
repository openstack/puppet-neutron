#
# Configure OVS to use OpenDaylight
#
# === Parameters
#
# [*tunnel_ip*]
# (required) The IP of the host to use for tunneling
# tenant VXLAN/GRE over
#
# [*odl_username*]
# (optional) The opendaylight controller username
# Defaults to 'admin'
#
# [*odl_password*]
# (optional) The opendaylight controller password
# Defaults to 'admin'
#
# [*odl_check_url*]
# (optional) The URL used to check ODL is available and ready
# Defaults to 'http://127.0.0.1:8080/restconf/operational/network-topology:network-topology/topology/netvirt:1'
#
# [*odl_ovsdb_iface*]
# (optional) The ODL southbound interface for OVSDB
# Defaults to 'tcp:127.0.0.1:6640'
#
# [*provider_mappings*]
# (optional) bridge mappings required if using VLAN
# tenant type.  Example: provider_mappings=br-ex:eth0
# Defaults to false
#
# [*retry_interval*]
# (optional) The time (in seconds) to wait between ODL availability checks
# Defaults to 60
#
# [*retry_count*]
# (optional) The number of ODL availability checks to run before failing
# Defaults to 20
#
class neutron::plugins::ovs::opendaylight (
  $tunnel_ip,
  $odl_username      = 'admin',
  $odl_password      = 'admin',
  $odl_check_url     = 'http://127.0.0.1:8080/restconf/operational/network-topology:network-topology/topology/netvirt:1',
  $odl_ovsdb_iface   = 'tcp:127.0.0.1:6640',
  $provider_mappings = false,
  $retry_interval     = 60,
  $retry_count        = 20,
) {
  # Handle the case where ODL controller is also on this host
  Service<| title == 'opendaylight' |> -> Exec <| title == 'Wait for NetVirt OVSDB to come up' |>

  exec { 'Wait for NetVirt OVSDB to come up':
    command   => "/bin/curl -o /dev/null --fail --silent --head -u ${odl_username}:${odl_password} ${odl_check_url}",
    tries     => $retry_count,
    try_sleep => $retry_interval,
  } ->
  # OVS manager
  exec { 'Set OVS Manager to OpenDaylight':
    command => "/usr/bin/ovs-vsctl set-manager ${odl_ovsdb_iface}",
    unless  => "/usr/bin/ovs-vsctl show | /usr/bin/grep 'Manager \"${odl_ovsdb_iface}\"'",
  } ->
  # local ip
  exec { 'Set local_ip Other Option':
    command => "/usr/bin/ovs-vsctl set Open_vSwitch $(ovs-vsctl get Open_vSwitch . _uuid) other_config:local_ip=${tunnel_ip}",
    unless  => "/usr/bin/ovs-vsctl list Open_vSwitch | /usr/bin/grep 'local_ip=\"${tunnel_ip}\"'",
  }

  # set mappings for VLAN
  if $provider_mappings {
    exec { 'Set provider_mappings Other Option':
      command => "/usr/bin/ovs-vsctl set Open_vSwitch $(ovs-vsctl get Open_vSwitch . _uuid) other_config:provider_mappings=${provider_mappings}",
      unless  => "/usr/bin/ovs-vsctl list Open_vSwitch | /usr/bin/grep 'provider_mappings' | /usr/bin/grep ${provider_mappings}",
    }
  }
}
