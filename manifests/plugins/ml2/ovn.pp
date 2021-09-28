# This class installs and configures the OVN Neutron plugin
#
# === Parameters
#
# [*ovn_nb_connection*]
#   (optional) The connection string for the OVN_Northbound OVSDB.
#   Defaults to 'tcp:127.0.0.1:6641'
#
# [*ovn_sb_connection*]
#   (optional) The connection string for the OVN_Southbound OVSDB
#   Defaults to 'tcp:127.0.0.1:6642'
#
# [*ovn_nb_private_key*]
#   (optional) The PEM file with private key for SSL connection to OVN-NB-DB
#   Defaults to $::os_service_default
#
# [*ovn_nb_certificate*]
#   (optional) The PEM file with certificate that certifies the private
#   key specified in ovn_nb_private_key
#   Defaults to $::os_service_default
#
# [*ovn_nb_ca_cert*]
#   (optional) The PEM file with CA certificate that OVN should use to
#   verify certificates presented to it by SSL peers
#   Defaults to $::os_service_default
#
# [*ovn_sb_private_key*]
#   (optional) The PEM file with private key for SSL connection to OVN-SB-DB
#   Defaults to $::os_service_default
#
# [*ovn_sb_certificate*]
#   (optional) The PEM file with certificate that certifies the
#   private key specified in ovn_sb_private_key
#   Defaults to $::os_service_default
#
# [*ovn_sb_ca_cert*]
#   (optional) The PEM file with CA certificate that OVN should use to
#   verify certificates presented to it by SSL peers
#   Defaults to $::os_service_default
#
# [*package_ensure*]
#   (optional) The intended state of the python-networking-odl
#   package, i.e. any of the possible values of the 'ensure'
#   property for a package resource type.
#   Defaults to 'present'
#
# [*ovsdb_connection_timeout*]
#   (optional) Timeout in seconds for the OVSDB connection transaction
#   Defaults to $::os_service_default
#
# [*ovsdb_retry_max_interval*]
#   (optional) Max intervla in seconds between each retry to get the OVN NB
#   and SB IDLs.
#   Defaults to $::os_service_default
#
# [*ovsdb_probe_interval*]
#   (optional) The probe interval for the OVSDB session in milliseconds.
#   Defaults to $::os_service_default.
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
#   Defaults to $::os_service_default
#
# [*vif_type*]
#   (optional) Type of VIF to be used for ports.
#   Valid values are 'ovs', 'vhostuser'
#   Defaults to $::os_service_default
#
# [*ovn_metadata_enabled*]
#   (optional) Whether to enable metadata service in OVN.
#   Type: boolean
#   Defaults to $::os_service_default
#
# [*dvr_enabled*]
#   (optional) Whether to enable DVR.
#   Type: boolean
#   Defaults to $::os_service_default
#
# [*dns_servers*]
#   (optional) List of dns servers which will be as forwarders
#              if a subnet's dns_nameservers is empty.
#   Type: List
#   Defaults to $::os_service_default
#
# [*vhostuser_socket_dir*]
#   (optional) The vhost-user socket directory for OVS
#   Type: String
#   Defaults to $::os_service_default
#
# [*ovn_emit_need_to_frag*]
#   (optional) Configure OVN to emit "need to frag" packets in case
#              of MTU mismatch. Before enabling this configuration make
#              sure that its supported by the host kernel (version >=
#              5.2) or by checking the output of the following command:
#              ovs-appctl -t ovs-vswitchd dpif/show-dp-features br-int |
#              grep "Check pkt length action".
#   Type: boolean
#   Defaults to $::os_service_default
#
# [*network_log_rate_limit*]
#   (Optional) Maximum packets logging per second.
#   Used by logging service plugin.
#   Defaults to $::os_service_default.
#   Minimum possible value is 100.
#
# [*network_log_burst_limit*]
#   (Optional) Maximum number of packets per rate_limit.
#   Used by logging service plugin.
#   Defaults to $::os_service_default.
#   Minimum possible value is 25.
#
# [*network_log_local_output_log_base*]
#   (Optional) Output logfile path on agent side, default syslog file.
#   Used by logging service plugin.
#   Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
# [*ovn_l3_mode*]
#   (optional) Whether to use OVN native L3 support. Do not change the
#   value for existing deployments that contain routers.
#   Type: boolean
#   Defaults to undef
#
class neutron::plugins::ml2::ovn(
  $ovn_nb_connection                 = $::os_service_default,
  $ovn_sb_connection                 = $::os_service_default,
  $ovn_nb_private_key                = $::os_service_default,
  $ovn_nb_certificate                = $::os_service_default,
  $ovn_nb_ca_cert                    = $::os_service_default,
  $ovn_sb_private_key                = $::os_service_default,
  $ovn_sb_certificate                = $::os_service_default,
  $ovn_sb_ca_cert                    = $::os_service_default,
  $package_ensure                    = 'present',
  $ovsdb_connection_timeout          = $::os_service_default,
  $ovsdb_retry_max_interval          = $::os_service_default,
  $ovsdb_probe_interval              = $::os_service_default,
  $neutron_sync_mode                 = $::os_service_default,
  $ovn_metadata_enabled              = $::os_service_default,
  $dvr_enabled                       = $::os_service_default,
  $dns_servers                       = $::os_service_default,
  $vhostuser_socket_dir              = $::os_service_default,
  $ovn_emit_need_to_frag             = $::os_service_default,
  $network_log_rate_limit            = $::os_service_default,
  $network_log_burst_limit           = $::os_service_default,
  $network_log_local_output_log_base = $::os_service_default,
  # DEPRECATED PARAMETERS
  $ovn_l3_mode                       = undef,
  $vif_type                          = undef,
) {

  include neutron::deps
  require neutron::plugins::ml2

  if $ovn_l3_mode != undef {
    warning('The ovn_l3_mode parameter has been deprecated and has no effect')
  }

  if $vif_type != undef {
    warning('The vif_type parameter has been deprecated and has no effect')
  }

  if ! ( $neutron_sync_mode in ['off', 'log', 'repair', $::os_service_default] ) {
    fail( 'Invalid value for neutron_sync_mode parameter' )
  }

  neutron_plugin_ml2 {
    'ovn/ovn_nb_connection'             : value => $ovn_nb_connection;
    'ovn/ovn_sb_connection'             : value => $ovn_sb_connection;
    'ovn/ovn_nb_private_key'            : value => $ovn_nb_private_key;
    'ovn/ovn_nb_certificate'            : value => $ovn_nb_certificate;
    'ovn/ovn_nb_ca_cert'                : value => $ovn_nb_ca_cert;
    'ovn/ovn_sb_private_key'            : value => $ovn_sb_private_key;
    'ovn/ovn_sb_certificate'            : value => $ovn_sb_certificate;
    'ovn/ovn_sb_ca_cert'                : value => $ovn_sb_ca_cert;
    'ovn/ovsdb_connection_timeout'      : value => $ovsdb_connection_timeout;
    'ovn/ovsdb_retry_max_interval'      : value => $ovsdb_retry_max_interval;
    'ovn/ovsdb_probe_interval'          : value => $ovsdb_probe_interval;
    'ovn/neutron_sync_mode'             : value => $neutron_sync_mode;
    'ovn/ovn_metadata_enabled'          : value => $ovn_metadata_enabled;
    'ovn/enable_distributed_floating_ip': value => $dvr_enabled;
    'ovn/dns_servers'                   : value => join(any2array($dns_servers), ',');
    'ovn/vhost_sock_dir'                : value => $vhostuser_socket_dir;
    'ovn/ovn_emit_need_to_frag'         : value => $ovn_emit_need_to_frag;
    'network_log/rate_limit'            : value => $network_log_rate_limit;
    'network_log/burst_limit'           : value => $network_log_burst_limit;
    'network_log/local_output_log_base' : value => $network_log_local_output_log_base;
  }

  # TODO(tkajinam): Remove this when removing the deprecated parameters
  neutron_plugin_ml2 {
    'ovn/ovn_l3_mode' : ensure => absent;
    'ovn/vif_type'    : ensure => absent;
  }
}
