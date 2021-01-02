# == Class: n1kv_vem
#
# DEPRECATED !
# Deploy N1KV VEM on compute and network nodes.
# Support exists and tested for RedHat.
# (For Ubuntu/Debian platforms few changes and testing pending.)
#
# === Parameters
# [*n1kv_vsm_ip*]
#   (required) N1KV VSM(Virtual Supervisor Module) VM's IP.
#   Defaults to 127.0.0.1
#
# [*n1kv_vsm_ipv6*]
#   (required) N1KV VSM(Virtual Supervisor Module) VM's IP.
#   Defaults to ::1
#
# [*n1kv_vsm_domain_id*]
#   (required) N1KV VSM DomainID.
#   Defaults to 1000
#
# [*host_mgmt_intf*]
#   (required) Management Interface of node where VEM will be installed.
#   Defaults to eth1
#
# [*uplink_profile*]
#   (optional) Uplink Interfaces that will be managed by VEM. The uplink
#      port-profile that configures these interfaces should also be specified.
#   (format)
#    $uplink_profile = { 'eth1' => 'profile1',
#                        'eth2' => 'profile2'
#                       },
#   Defaults to empty
#
# [*vtep_config*]
#   (optional) Virtual tunnel interface configuration.
#              Eg:VxLAN tunnel end-points.
#   (format)
#   $vtep_config = { 'vtep1' => { 'profile' => 'virtprof1',
#                                 'ipmode'  => 'dhcp'
#                               },
#                    'vtep2' => { 'profile'   => 'virtprof2',
#                                 'ipmode'    => 'static',
#                                 'ipaddress' => '192.168.1.1',
#                                 'netmask'   => '255.255.255.0'
#                               }
#                  },
#   Defaults to empty
#
# [*node_type*]
#   (optional). Specify the type of node: 'compute' (or) 'network'.
#   Defaults to 'compute'
#
# All the above parameter values will be used in the config file: n1kv.conf
#
# [*vteps_in_same_subnet*]
#   (optional)
#   The VXLAN tunnel interfaces created on VEM can belong to same IP-subnet.
#   In such case, set this parameter to true. This results in below
#   'sysctl:ipv4' values to be modified.
#     rp_filter (reverse path filtering) set to 2(Loose).Default is 1(Strict)
#     arp_ignore (arp reply mode) set to 1:reply only if target ip matches
#                                that of incoming interface. Default is 0
#     arp_announce (arp announce mode) set to 1. Default is 0
#   Please refer Linux Documentation for detailed description
#   http://lxr.free-electrons.com/source/Documentation/networking/ip-sysctl.txt
#
#   If the tunnel interfaces are not in same subnet set this parameter to false.
#   Note that setting to false causes no change in the sysctl settings and does
#   not revert the changes made if it was originally set to true on a previous
#   catalog run.
#
#   Defaults to false
#
# [*n1kv_source*]
#   (optional)
#     n1kv_source ==> VEM package location. One of below
#       A)URL of yum repository that hosts VEM package.
#       B)VEM RPM/DPKG file name, If present locally in 'files' folder
#       C)If not specified, assumes that VEM image is available in
#         default enabled repositories.
#   Defaults to empty
#
# [*n1kv_version*]
#   (optional). Specify VEM package version to be installed.
#       Not applicable if 'n1kv_source' is a file. (Option-B above)
#   Defaults to 'present'
#
# [*package_ensure*]
#   (optional) Ensure state for dependent packages: Openvswitch/libnl.
#   Defaults to 'present'.
#
# [*enable*]
#   (optional) Enable state for service. Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*portdb*]
#   (optional) PortDB (ovs|vem)
#   Defaults to ovs
#
# [*fastpath_flood*]
#   (optional) Handle broadcast floods and unknown pkts in fastpath(KLM)
#   Defaults to enable
#
class neutron::agents::n1kv_vem (
  $n1kv_vsm_ip          = '127.0.0.1',
  $n1kv_vsm_ipv6        = '::1',
  $n1kv_vsm_domain_id   = 1000,
  $host_mgmt_intf       = 'eth1',
  $uplink_profile       = {},
  $vtep_config          = {},
  $node_type            = 'compute',
  $vteps_in_same_subnet = false,
  $n1kv_source          = '',
  $n1kv_version         = 'present',
  $package_ensure       = 'present',
  $enable               = true,
  $manage_service       = true,
  $portdb               = 'ovs',
  $fastpath_flood       = 'enable'
) {

  warning('The support N1kv driver was deprecated and has no effect')
}
