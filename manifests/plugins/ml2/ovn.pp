# This class installs and configures the OVN Neutron plugin
#
# === Parameters
#
# [*ovn_nb_connection*]
#   (optional) The connection string for the OVN_Northbound OVSDB.
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_connection*]
#   (optional) The connection string for the OVN_Southbound OVSDB
#   Defaults to $facts['os_service_default']
#
# [*ovn_nb_private_key*]
#   (optional) The PEM file with private key for SSL connection to OVN-NB-DB
#   Defaults to $facts['os_service_default']
#
# [*ovn_nb_certificate*]
#   (optional) The PEM file with certificate that certifies the private
#   key specified in ovn_nb_private_key
#   Defaults to $facts['os_service_default']
#
# [*ovn_nb_ca_cert*]
#   (optional) The PEM file with CA certificate that OVN should use to
#   verify certificates presented to it by SSL peers
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_private_key*]
#   (optional) The PEM file with private key for SSL connection to OVN-SB-DB
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_certificate*]
#   (optional) The PEM file with certificate that certifies the
#   private key specified in ovn_sb_private_key
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_ca_cert*]
#   (optional) The PEM file with CA certificate that OVN should use to
#   verify certificates presented to it by SSL peers
#   Defaults to $facts['os_service_default']
#
# [*package_ensure*]
#   (optional) The intended state of the python-networking-odl
#   package, i.e. any of the possible values of the 'ensure'
#   property for a package resource type.
#   Defaults to 'present'
#
# [*ovsdb_connection_timeout*]
#   (optional) Timeout in seconds for the OVSDB connection transaction
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_retry_max_interval*]
#   (optional) Max interval in seconds between each retry to get the OVN NB
#   and SB IDLs.
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_probe_interval*]
#   (optional) The probe interval for the OVSDB session in milliseconds.
#   Defaults to $facts['os_service_default'].
#
# [*neutron_sync_mode*]
#   (optional) The synchronization mode of OVN with Neutron DB.
#   Valid values are - 'log', 'off', 'repair'
#   off - synchronization is off
#   log - during neutron-server startup check to see if OVN is in sync with
#         the Neutron database. Log warnings for any inconsistencies found so
#         that an admin can investigate.
#   repair - during neutron-server startup, automatically create resources
#            found in Neutron but not in OVN. Also remove resources from OVN
#            that are no longer in Neutron.
#   Defaults to $facts['os_service_default']
#
# [*ovn_l3_scheduler*]
#   (optional) The OVN L3 Scheduler type used to schedule router gateway ports
#   on hypervisors/chassis.
#   Defaults to $facts['os_service_default']
#
# [*ovn_metadata_enabled*]
#   (optional) Whether to enable metadata service in OVN.
#   Type: boolean
#   Defaults to $facts['os_service_default']
#
# [*dvr_enabled*]
#   (optional) Whether to enable DVR.
#   Type: boolean
#   Defaults to $facts['os_service_default']
#
# [*disable_ovn_dhcp_for_baremetal_ports*]
#   (optional) Whether to disable built-in DHCP for baremetal ports.
#   Type: boolean
#   Defaults to $facts['os_service_default']
#
# [*dns_servers*]
#   (optional) List of dns servers which will be as forwarders if a subnet's
#   dns_nameservers is empty.
#   Type: List
#   Defaults to $facts['os_service_default']
#
# [*dns_records_ovn_owned*]
#   (optional) Whether to consider DNS records local to OVN or not.
#   Type: boolean
#   Defaults to $facts['os_service_default']
#
# [*vhostuser_socket_dir*]
#   (optional) The vhost-user socket directory for OVS
#   Type: String
#   Defaults to $facts['os_service_default']
#
# [*dhcp_default_lease_time*]
#   (optional) Default lease time (in seconds) to use with OVN's native DHCP
#   service.
#   Defaults to $facts['os_service_default']
#
# [*ovn_dhcp4_global_options*]
#   (optional) Global DHCP6 options which will be automatically set on each
#   subnet upon creation and on all existing subnets when Neutron starts.
#   Defaults to $facts['os_service_default']
#
# [*ovn_dhcp6_global_options*]
#   (optional) Global DHCP6 options which will be automatically set on each
#   subnet upon creation and on all existing subnets when Neutron starts.
#   Defaults to $facts['os_service_default']
#
# [*localnet_learn_fdb*]
#   (optional) If enabled it will allow localnet ports to learn MAC addresses
#              and store them in FDB SB table. This avoids flooding for
#              traffic towards unknown IPs when port security is disable.
#              It requires OVN 22.09 or newer.
#   Type: boolean
#   Defaults to $facts['os_service_default']
#
# [*fdb_age_threshold*]
#   (optional) The number of seconds to keep FD entries in the OVN DB.
#   Defaults to $facts['os_service_default']
#
# [*mac_binding_age_threshold*]
#   (optional) The number of seconds to keep MAC_Binding entries in the OVN DB.
#   Defaults to $facts['os_service_default']
#
# [*broadcast_arps_to_all_routers*]
#   (optional) If enabled OVM will flood ARP requests to all attached ports on
#   a network. Supported by OVM >= 23.06.
#   Type: boolean
#   Defaults to $facts['os_service_default']
#
# [*ovn_router_indirect_snat*]
#   (optional) Whether to configure SNAT for all nested subnets connected to
#   the router through any routers.
#   Defaults to $facts['os_service_default']
#
# [*live_migration_activation_strategy*]
#   (optional) Activation strategy to use for live migration.
#   Defaults to $facts['os_service_default']
#
# [*ignore_lsp_down*]
#   (optional) Do not install ARP/ND reply flows for logical switch ports
#   if the port is DOWN.
#   Defaults to $facts['os_service_default']
#
# [*fdb_removal_limit*]
#   (optional) FDB aging bulk removal limit.
#   Defaults to $facts['os_service_default']
#
# [*mac_binding_removal_limit*]
#   (optional) MAC binding aging bulk removal limit.
#   Defaults to $facts['os_service_default']
#
# [*network_log_rate_limit*]
#   (Optional) Maximum packets logging per second.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#   Minimum possible value is 100.
#
# [*network_log_burst_limit*]
#   (Optional) Maximum number of packets per rate_limit.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#   Minimum possible value is 25.
#
# [*network_log_local_output_log_base*]
#   (Optional) Output logfile path on agent side, default syslog file.
#   Used by logging service plugin.
#   Defaults to $facts['os_service_default'].
#
# DEPRECATED PARAMETERS
#
# [*ovn_emit_need_to_frag*]
#   (optional) Configure OVN to emit "need to frag" packets in case of MTU
#   mismatch. Before enabling this configuration make sure that its supported
#   by the host kernel (version >= 5.2) or by checking the output of
#   the following command:
#     ovs-appctl -t ovs-vswitchd dpif/show-dp-features br-int |
#     grep "Check pkt length action".
#   Type: boolean
#   Defaults to $facts['os_service_default']
#
class neutron::plugins::ml2::ovn(
  $ovn_nb_connection                    = $facts['os_service_default'],
  $ovn_sb_connection                    = $facts['os_service_default'],
  $ovn_nb_private_key                   = $facts['os_service_default'],
  $ovn_nb_certificate                   = $facts['os_service_default'],
  $ovn_nb_ca_cert                       = $facts['os_service_default'],
  $ovn_sb_private_key                   = $facts['os_service_default'],
  $ovn_sb_certificate                   = $facts['os_service_default'],
  $ovn_sb_ca_cert                       = $facts['os_service_default'],
  $package_ensure                       = 'present',
  $ovsdb_connection_timeout             = $facts['os_service_default'],
  $ovsdb_retry_max_interval             = $facts['os_service_default'],
  $ovsdb_probe_interval                 = $facts['os_service_default'],
  $neutron_sync_mode                    = $facts['os_service_default'],
  $ovn_l3_scheduler                     = $facts['os_service_default'],
  $ovn_metadata_enabled                 = $facts['os_service_default'],
  $dvr_enabled                          = $facts['os_service_default'],
  $disable_ovn_dhcp_for_baremetal_ports = $facts['os_service_default'],
  $dns_servers                          = $facts['os_service_default'],
  $dns_records_ovn_owned                = $facts['os_service_default'],
  $vhostuser_socket_dir                 = $facts['os_service_default'],
  $dhcp_default_lease_time              = $facts['os_service_default'],
  $ovn_dhcp4_global_options             = $facts['os_service_default'],
  $ovn_dhcp6_global_options             = $facts['os_service_default'],
  $localnet_learn_fdb                   = $facts['os_service_default'],
  $fdb_age_threshold                    = $facts['os_service_default'],
  $mac_binding_age_threshold            = $facts['os_service_default'],
  $broadcast_arps_to_all_routers        = $facts['os_service_default'],
  $ovn_router_indirect_snat             = $facts['os_service_default'],
  $live_migration_activation_strategy   = $facts['os_service_default'],
  $ignore_lsp_down                      = $facts['os_service_default'],
  $fdb_removal_limit                    = $facts['os_service_default'],
  $mac_binding_removal_limit            = $facts['os_service_default'],
  $network_log_rate_limit               = $facts['os_service_default'],
  $network_log_burst_limit              = $facts['os_service_default'],
  $network_log_local_output_log_base    = $facts['os_service_default'],
  # DEPRECATED PARAMETERS
  $ovn_emit_need_to_frag                = undef,
) {

  include neutron::deps
  require neutron::plugins::ml2

  if $ovn_emit_need_to_frag != undef {
    warning('The ovn_emit_need_to_frag parameter has been deprecated.')
  }

  if ! ( $neutron_sync_mode in ['off', 'log', 'repair', $facts['os_service_default']] ) {
    fail( 'Invalid value for neutron_sync_mode parameter' )
  }

  $ovn_dhcp4_global_options_real = $ovn_dhcp4_global_options ? {
    Hash    => join(join_keys_to_values($ovn_dhcp4_global_options, ':'), ','),
    default => join(any2array($ovn_dhcp4_global_options), ',')
  }
  $ovn_dhcp6_global_options_real = $ovn_dhcp6_global_options ? {
    Hash    => join(join_keys_to_values($ovn_dhcp6_global_options, ':'), ','),
    default => join(any2array($ovn_dhcp6_global_options), ',')
  }

  neutron_plugin_ml2 {
    'ovn/ovn_nb_connection'                   : value => join(any2array($ovn_nb_connection), ',');
    'ovn/ovn_sb_connection'                   : value => join(any2array($ovn_sb_connection), ',');
    'ovn/ovn_nb_private_key'                  : value => $ovn_nb_private_key;
    'ovn/ovn_nb_certificate'                  : value => $ovn_nb_certificate;
    'ovn/ovn_nb_ca_cert'                      : value => $ovn_nb_ca_cert;
    'ovn/ovn_sb_private_key'                  : value => $ovn_sb_private_key;
    'ovn/ovn_sb_certificate'                  : value => $ovn_sb_certificate;
    'ovn/ovn_sb_ca_cert'                      : value => $ovn_sb_ca_cert;
    'ovn/ovsdb_connection_timeout'            : value => $ovsdb_connection_timeout;
    'ovn/ovsdb_retry_max_interval'            : value => $ovsdb_retry_max_interval;
    'ovn/ovsdb_probe_interval'                : value => $ovsdb_probe_interval;
    'ovn/neutron_sync_mode'                   : value => $neutron_sync_mode;
    'ovn/ovn_l3_scheduler'                    : value => $ovn_l3_scheduler;
    'ovn/ovn_metadata_enabled'                : value => $ovn_metadata_enabled;
    'ovn/enable_distributed_floating_ip'      : value => $dvr_enabled;
    'ovn/disable_ovn_dhcp_for_baremetal_ports': value => $disable_ovn_dhcp_for_baremetal_ports;
    'ovn/dns_servers'                         : value => join(any2array($dns_servers), ',');
    'ovn/dns_records_ovn_owned'               : value => $dns_records_ovn_owned;
    'ovn/vhost_sock_dir'                      : value => $vhostuser_socket_dir;
    'ovn/dhcp_default_lease_time'             : value => $dhcp_default_lease_time;
    'ovn/ovn_dhcp4_global_options'            : value => $ovn_dhcp4_global_options_real;
    'ovn/ovn_dhcp6_global_options'            : value => $ovn_dhcp6_global_options_real;
    'ovn/ovn_emit_need_to_frag'               : value => pick($ovn_emit_need_to_frag, $facts['os_service_default']);
    'ovn/localnet_learn_fdb'                  : value => $localnet_learn_fdb;
    'ovn/fdb_age_threshold'                   : value => $fdb_age_threshold;
    'ovn/mac_binding_age_threshold'           : value => $mac_binding_age_threshold;
    'ovn/broadcast_arps_to_all_routers'       : value => $broadcast_arps_to_all_routers;
    'ovn/ovn_router_indirect_snat'            : value => $ovn_router_indirect_snat;
    'ovn/live_migration_activation_strategy'  : value => $live_migration_activation_strategy;
    'ovn_nb_global/ignore_lsp_down'           : value => $ignore_lsp_down;
    'ovn_nb_global/fdb_removal_limit'         : value => $fdb_removal_limit;
    'ovn_nb_global/mac_binding_removal_limit' : value => $mac_binding_removal_limit;
    'network_log/rate_limit'                  : value => $network_log_rate_limit;
    'network_log/burst_limit'                 : value => $network_log_burst_limit;
    'network_log/local_output_log_base'       : value => $network_log_local_output_log_base;
  }
}
