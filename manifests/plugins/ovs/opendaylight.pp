#
# Configure OVS to use OpenDaylight
#
# === Parameters
#
# [*tunnel_ip*]
#   (required) The IP of the host to use for tunneling tenant VXLAN/GRE over
#
# [*odl_username*]
#   (optional) The opendaylight controller username
#
# [*odl_password*]
#   (optional) The opendaylight controller password
#
# [*odl_check_url*]
#   (optional) The URL used to check ODL is available and ready
#   Defaults to 'http://127.0.0.1:8080/restconf/operational/network-topology:network-topology/topology/netvirt:1'
#
# [*odl_ovsdb_iface*]
#   (optional) The ODL southbound interface for OVSDB
#   Defaults to 'tcp:127.0.0.1:6640'
#
# [*ovsdb_server_iface*]
#   (optional) The interface for OVSDB local server to listen on
#   Defaults to 'ptcp:6639:127.0.0.1'
#
# [*provider_mappings*]
#   (optional) List of <physical_network>:<nic/bridge>
#   Required for VLAN provider networks.
#   Required for Flat provider networks when using new NetVirt
#   Defaults to empty list
#
# [*retry_interval*]
#   (optional) The time (in seconds) to wait between ODL availability checks
#   Defaults to 60
#
# [*retry_count*]
#   (optional) The number of ODL availability checks to run before failing
#   Defaults to 20
#
# [*host_id*]
#   (optional) The desired hostname for this node
#   Defaults to FQDN hostname of the server
#
# [*allowed_network_types*]
#   (optional) List of network_types to allocate as tenant networks.
#   The value 'local' is only useful for single-box testing
#   but provides no connectivity between hosts.
#   Should be an array that can have these elements:
#   local, vlan, gre, vxlan
#   Defaults to ['local', 'vlan', 'gre', 'vxlan']
#
# [*enable_dpdk*]
#   (optional) Enables vhostuser VIF host configuration for OVS DPDK.
#   Defaults to false.
#
# [*vhostuser_socket_dir*]
#   (optional) Specify the directory to use for vhostuser sockets.
#   Defaults to "/var/run/openvswitch"
#
# [*vhostuser_mode*]
#   (optional) Specify the mode for OVS when creating vhostuser ports.
#   Valid values are 'client' or 'server'.  In client mode, the hypervisor
#   will be responsible for creating the vhostuser socket.  In server mode,
#   OVS will create the vhostuser socket.
#   Defaults to "client"
#
class neutron::plugins::ovs::opendaylight (
  $tunnel_ip,
  $odl_username,
  $odl_password,
  $odl_check_url         = 'http://127.0.0.1:8080/restconf/operational/network-topology:network-topology/topology/netvirt:1',
  $odl_ovsdb_iface       = 'tcp:127.0.0.1:6640',
  $ovsdb_server_iface    = 'ptcp:6639:127.0.0.1',
  $provider_mappings     = [],
  $retry_interval        = 60,
  $retry_count           = 20,
  $host_id               = $fqdn,
  $allowed_network_types = ['local', 'vlan', 'vxlan', 'gre'],
  $enable_dpdk           = false,
  $vhostuser_socket_dir  = '/var/run/openvswitch',
  $vhostuser_mode        = 'client'
) {

  include ::neutron::deps

  # Handle the case where ODL controller is also on this host
  Service<| title == 'opendaylight' |> -> Exec <| title == 'Wait for NetVirt OVSDB to come up' |>

  exec { 'Wait for NetVirt OVSDB to come up':
    command   => "curl -o /dev/null --fail --silent --head -u ${odl_username}:${odl_password} ${odl_check_url}",
    tries     => $retry_count,
    try_sleep => $retry_interval,
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
  }
  # OVS manager
  -> exec { 'Set OVS Manager to OpenDaylight':
      command => "ovs-vsctl set-manager ${ovsdb_server_iface} ${odl_ovsdb_iface}",
      unless  => "ovs-vsctl show | grep 'Manager \"${ovsdb_server_iface} ${odl_ovsdb_iface}\"'",
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # local ip
  vs_config {'other_config:local_ip':
    value => $tunnel_ip,
  }

  # set mappings for VLAN or Flat provider networks
  if $provider_mappings and ! empty($provider_mappings) {
    $pr_map_str = join(any2array($provider_mappings), ',')
    vs_config {'other_config:provider_mappings':
      value => $pr_map_str
    }
  }

  # host config for pseudo agent binding type
  vs_config {'external_ids:odl_os_hostconfig_hostid':
    value => $host_id,
  }

  $json_network_types = convert_to_json_string($allowed_network_types)
  $json_bridge_mappings = convert_to_json_string($provider_mappings)

  if $enable_dpdk {
    $host_config = @("END":json/$L)
      {\
        "supported_vnic_types": [{\
          "vnic_type": "normal",\
          "vif_type": "vhostuser",\
          "vif_details": {\
            "uuid": "${::ovs_uuid}",\
            "has_datapath_type_netdev": true,\
            "port_prefix": "vhu_",\
            "vhostuser_socket_dir": "${vhostuser_socket_dir}",\
            "vhostuser_ovs_plug": true,\
            "vhostuser_mode": "${vhostuser_mode}",\
            "vhostuser_socket": "${vhostuser_socket_dir}/vhu_\$PORT_ID"\
          }\
        }],\
        "allowed_network_types": ${json_network_types},\
        "bridge_mappings": ${json_bridge_mappings}\
      }
      |-END
  } else {
    $host_config = @("END":json/L)
      {\
        "supported_vnic_types": [{\
          "vnic_type": "normal",\
          "vif_type": "ovs",\
          "vif_details": {}\
        }],\
        "allowed_network_types": ${json_network_types},\
        "bridge_mappings": ${json_bridge_mappings}\
      }
      |-END
  }

  vs_config {'external_ids:odl_os_hostconfig_config_odl_l2':
    value => $host_config
  }
}
