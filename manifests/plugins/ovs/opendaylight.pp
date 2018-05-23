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
#   local, flat, vlan, gre, vxlan
#   Defaults to ['local', 'flat', 'vlan', 'gre', 'vxlan']
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
#   (optional) Specify the mode for the VIF when creating vhostuser ports.
#   Valid values are 'client' or 'server'.  In client mode, openvswitch
#   will be responsible for creating the vhostuser socket.  In server mode,
#   the hypervisor will create the vhostuser socket.
#   Defaults to "server"
#
# [*enable_hw_offload*]
#   (optional) Configure OVS to use
#   Hardware Offload. This feature is
#   supported from ovs 2.8.0.
#   Defaults to False.
#
# [*enable_tls*]
#   (optional) Configure OVS to use SSL/TLS
#   Defaults to False.
#
# [*tls_key_file*]
#   (optional) Private key file path to use for TLS configuration
#   Defaults to False.  Required if enabling TLS.
#
# [*tls_cert_file*]
#   (optional) Certificate file path to use for TLS configuration
#   Defaults to False.  Required if enabling TLS.
#
# [*tls_ca_cert_file*]
#   (optional) CA Certificate file path to use for TLS configuration
#   Defaults to False.
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
  $allowed_network_types = ['local', 'flat', 'vlan', 'vxlan', 'gre'],
  $enable_dpdk           = false,
  $vhostuser_socket_dir  = '/var/run/openvswitch',
  $vhostuser_mode        = 'server',
  $enable_hw_offload     = false,
  $enable_tls            = false,
  $tls_key_file          = undef,
  $tls_cert_file         = undef,
  $tls_ca_cert_file      = undef
) {

  include ::neutron::deps

  # Handle the case where ODL controller is also on this host
  Service<| title == 'opendaylight' |> -> Exec <| title == 'Wait for NetVirt OVSDB to come up' |>

  if $enable_tls {
    if empty($tls_key_file) or empty($tls_cert_file) {
      fail('When enabling TLS, tls_key_file and tls_cert_file must be provided')
    }
    if ! empty($tls_ca_cert_file) {
      vs_ssl { 'system':
        ensure    => present,
        key_file  => $tls_key_file,
        cert_file => $tls_cert_file,
        ca_file   => $tls_ca_cert_file,
        before    => Exec['Set OVS Manager to OpenDaylight']
      }
    } else {
      vs_ssl { 'system':
        ensure    => present,
        key_file  => $tls_key_file,
        cert_file => $tls_cert_file,
        bootstrap => true,
        before    => Exec['Set OVS Manager to OpenDaylight']
      }
    }

    if $odl_ovsdb_iface =~ /^tcp/ {
      warning('TLS enabled but odl_ovsdb_iface set to tcp.  Will override to ssl')
      $odl_ovsdb_iface_parsed = regsubst($odl_ovsdb_iface, 'tcp:', 'ssl:', 'G')
    } else {
      $odl_ovsdb_iface_parsed = $odl_ovsdb_iface
    }

    if $ovsdb_server_iface =~ /^ptcp/ {
      warning('TLS enabled but ovsdb_server_iface set to ptcp.  Will override to pssl')
      $ovsdb_server_iface_parsed = regsubst($ovsdb_server_iface, '^ptcp', 'pssl')
    } else {
      $ovsdb_server_iface_parsed = $ovsdb_server_iface
    }

    if $odl_check_url =~ /^http:/ {
      warning('TLS enabled but odl_check_url set to http.  Will override to https')
      $odl_check_url_parsed = regsubst($odl_check_url, '^http:', 'https:')
    } else {
      $odl_check_url_parsed = $odl_check_url
    }

    $cert_data = convert_cert_to_string($tls_cert_file)
    $rest_data = @("END":json/L)
      {\
        "aaa-cert-rpc:input": {\
        "aaa-cert-rpc:node-alias": "${::hostname}",\
        "aaa-cert-rpc:node-cert": "${cert_data}"\
        }\
      }
      |-END

    $curl_post = "curl -k -X POST -o /dev/null --fail --silent -H 'Content-Type: application/json' -H 'Cache-Control: no-cache'"
    $curl_get = "curl -k -X POST --fail --silent -H 'Content-Type: application/json' -H 'Cache-Control: no-cache'"
    $rest_get_data = @("END":json/L)
      {\
        "aaa-cert-rpc:input": {\
        "aaa-cert-rpc:node-alias": "${::hostname}"\
        }\
      }
      |-END

    $ovsdb_arr = split($odl_ovsdb_iface_parsed, ' ')
    $odl_rest_port = regsubst($odl_check_url_parsed, '^.*:([0-9]+)/.*$', '\1')
    $ovsdb_arr.each |$ovsdb_uri| {

      $odl_ip = regsubst($ovsdb_uri, 'ssl:(.+):[0-9]+', '\1')
      $odl_url_prefix = "https://${odl_ip}:${odl_rest_port}"
      $cert_rest_url = "${odl_url_prefix}/restconf/operations/aaa-cert-rpc:setNodeCertifcate"
      $cert_rest_get = "${odl_url_prefix}/restconf/operations/aaa-cert-rpc:getNodeCertifcate"
      exec { "Add trusted cert: ${tls_cert_file} to ${odl_url_prefix}":
        command   => "${curl_post} -u ${odl_username}:${odl_password} -d '${rest_data}' ${cert_rest_url}",
        tries     => 5,
        try_sleep => 30,
        unless    => "${curl_get} -u ${odl_username}:${odl_password} -d '${rest_get_data}' ${cert_rest_get} | grep -q ${cert_data}",
        path      => '/usr/sbin:/usr/bin:/sbin:/bin',
        before    => Exec['Set OVS Manager to OpenDaylight'],
        require   => Exec['Wait for NetVirt OVSDB to come up']
      }
    }

  } else {
    $odl_ovsdb_iface_parsed = $odl_ovsdb_iface
    $ovsdb_server_iface_parsed = $ovsdb_server_iface
    $odl_check_url_parsed = $odl_check_url
  }

  exec { 'Wait for NetVirt OVSDB to come up':
    command   => "curl -k -o /dev/null --fail --silent --head -u ${odl_username}:${odl_password} ${odl_check_url_parsed}",
    tries     => $retry_count,
    try_sleep => $retry_interval,
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
  }
  # OVS manager
  -> exec { 'Set OVS Manager to OpenDaylight':
      command => "ovs-vsctl set-manager ${ovsdb_server_iface_parsed} ${odl_ovsdb_iface_parsed}",
      unless  => "ovs-vsctl show | grep 'Manager \"${ovsdb_server_iface_parsed} ${odl_ovsdb_iface_parsed}\"'",
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

  # Set hostname to FQDN instead of default 'localhost'
  vs_config {'external_ids:hostname':
    value => $host_id,
  }

  $json_network_types = convert_to_json_string($allowed_network_types)
  $json_bridge_mappings = convert_to_json_string($provider_mappings)

  if $enable_hw_offload and $enable_dpdk {
    fail('Enabling hardware offload and DPDK is not allowed')
  }

  if $enable_dpdk {
    $host_config = @("END":json/$L)
      {\
        "supported_vnic_types": [{\
          "vnic_type": "normal",\
          "vif_type": "vhostuser",\
          "vif_details": {\
            "uuid": "${::ovs_uuid}",\
            "has_datapath_type_netdev": true,\
            "port_prefix": "vhu",\
            "vhostuser_socket_dir": "${vhostuser_socket_dir}",\
            "vhostuser_ovs_plug": true,\
            "vhostuser_mode": "${vhostuser_mode}",\
            "vhostuser_socket": "${vhostuser_socket_dir}/vhu\$PORT_ID"\
          }\
        }],\
        "allowed_network_types": ${json_network_types},\
        "bridge_mappings": ${json_bridge_mappings}\
      }
      |-END
  } elsif $enable_hw_offload {
    require ::vswitch::ovs
    $host_config = @("END":json/L)
      {\
        "supported_vnic_types": [{\
          "vnic_type": "normal",\
          "vif_type": "ovs",\
          "vif_details": {}\
        },{\
          "vnic_type": "direct",\
          "vif_type": "ovs",\
          "vif_details": {}\
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
