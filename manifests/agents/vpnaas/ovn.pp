# == Class: neutron::agents:vpnaas::ovn
#
# Setups Neutron OVN VPN agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enabled*]
#   (optional) State of the service. Defaults to true.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   (optional) Debug. Defaults to $facts['os_service_default'].
#
# [*vpn_device_driver*]
#   (optional) The vpn device drivers Neutron will us.
#   Defaults to 'neutron_vpnaas.services.vpn.device_drivers.ovn_ipsec.OvnOpenSwanDriver'.
#
# [*interface_driver*]
#   (optional) The driver used to manage the virtual interface.
#   Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*ipsec_status_check_interval*]
#   (optional) Status check interval. Defaults to $facts['os_service_default'].
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the ovn vpn agent config.
#   Defaults to false.
#
# [*ovsdb_connection*]
#   (optional) The URI used to connect to the local OVSDB server.
#   Defaults to 'tcp:127.0.0.1:6640'
#
# [*ovs_manager*]
#   The manager target that will be set to OVS so that the metadata agent can
#   connect to.
#   Defaults to 'ptcp:6640:127.0.0.1'
#
# [*ovn_sb_connection*]
#   (optional) The connection string for the OVN_Southbound OVSDB
#   Defaults to '$facts['os_service_default']'
#
# [*ovn_sb_private_key*]
#   (optional) TThe PEM file with private key for SSL connection to OVN-SB-DB
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_certificate*]
#   (optional) The PEM file with certificate that certifies the
#   private key specified in ovn_sb_private_key
#   Defaults to $facts['os_service_default']
#
# [*ovn_sb_ca_cert*]
#   (optional) TThe PEM file with CA certificate that OVN should use to
#   verify certificates presented to it by SSL peers
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_connection_timeout*]
#   (optional) Timeout in seconds for the OVSDB connection transaction.
#   Defaults to $facts['os_service_default']
#
# [*ovndb_connection_timeout*]
#   (optional) Timeout in seconds for the OVNDB connection transaction. This
#   is used for OVN DB connection.
#   Defaults to $facts['os_service_default']
#
# [*ovsdb_retry_max_interval*]
#   (optional) Max interval in seconds between each retry to get the OVN NB
#   and SB IDLs.
#   Defaults to $facts['os_service_default'].
#
# [*ovsdb_probe_interval*]
#   (optional) The probe interval for the OVSDB session in milliseconds.
#   Defaults to $facts['os_service_default'].
#
class neutron::agents::vpnaas::ovn (
  Stdlib::Ensure::Package $package_ensure = present,
  Boolean $enabled                        = true,
  Boolean $manage_service                 = true,
  $debug                                  = $facts['os_service_default'],
  $vpn_device_driver                      = 'neutron_vpnaas.services.vpn.device_drivers.ovn_ipsec.OvnOpenSwanDriver',
  $interface_driver                       = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $ipsec_status_check_interval            = $facts['os_service_default'],
  $ovsdb_connection                       = 'tcp:127.0.0.1:6640',
  $ovs_manager                            = 'ptcp:6640:127.0.0.1',
  $ovn_sb_connection                      = $facts['os_service_default'],
  $ovn_sb_private_key                     = $facts['os_service_default'],
  $ovn_sb_certificate                     = $facts['os_service_default'],
  $ovn_sb_ca_cert                         = $facts['os_service_default'],
  $ovsdb_connection_timeout               = $facts['os_service_default'],
  $ovndb_connection_timeout               = $facts['os_service_default'],
  $ovsdb_retry_max_interval               = $facts['os_service_default'],
  $ovsdb_probe_interval                   = $facts['os_service_default'],
  Boolean $purge_config                   = false,
) {
  include neutron::deps
  include neutron::params

  if $facts['os']['family'] != 'RedHat' {
    fail('The OVN VPN agent service is now supported in Red Hat os family only.')
  }

  case $vpn_device_driver {
    /\.OvnOpenSwanDriver$/: {
      warning("Support for OpenSwan has been deprecated, because of lack of \
openswan package in distributions")
    }
    /\.OvnLibreSwanDriver$/: {
      stdlib::ensure_packages( 'libreswan', {
        'ensure' => present,
        'name'   => $neutron::params::libreswan_package,
        'tag'    => ['openstack', 'neutron-support-package'],
      })
    }
    /\.OvnStrongSwanDriver$/: {
      stdlib::ensure_packages( 'strongswan', {
        'ensure' => present,
        'name'   => $neutron::params::strongswan_package,
        'tag'    => ['openstack', 'neutron-support-package'],
      })
    }
    default: {
      fail("Unsupported vpn_device_driver ${vpn_device_driver}")
    }
  }

  resources { 'neutron_ovn_vpn_agent_config':
    purge => $purge_config,
  }

  # The OVN VPNaaS agent loads both neutron.conf and its own file.
  # This only lists config specific to the agent.  neutron.conf supplies
  # the rest.
  neutron_ovn_vpn_agent_config {
    'DEFAULT/debug':                     value => $debug;
    'vpnagent/vpn_device_driver':        value => $vpn_device_driver;
    'ipsec/ipsec_status_check_interval': value => $ipsec_status_check_interval;
    'DEFAULT/interface_driver':          value => $interface_driver;
    'ovs/ovsdb_connection':              value => $ovsdb_connection;
    'ovs/ovsdb_connection_timeout':      value => $ovsdb_connection_timeout;
    'ovn/ovsdb_connection_timeout':      value => $ovndb_connection_timeout;
    'ovn/ovsdb_retry_max_interval':      value => $ovsdb_retry_max_interval;
    'ovn/ovsdb_probe_interval':          value => $ovsdb_probe_interval;
    'ovn/ovn_sb_connection':             value => join(any2array($ovn_sb_connection), ',');
    'ovn/ovn_sb_private_key':            value => $ovn_sb_private_key;
    'ovn/ovn_sb_certificate':            value => $ovn_sb_certificate;
    'ovn/ovn_sb_ca_cert':                value => $ovn_sb_ca_cert;
  }

  stdlib::ensure_packages( 'neutron-vpnaas-ovn-vpn-agent', {
    'ensure' => $package_ensure,
    'name'   => $neutron::params::vpnaas_ovn_vpn_agent_package,
    'tag'    => ['openstack', 'neutron-package'],
  })

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    service { 'neutron-vpnaas-ovn-vpn-agent':
      ensure => $service_ensure,
      name   => $neutron::params::vpnaas_ovn_vpn_agent_service,
      enable => $enabled,
      tag    => 'neutron-service',
    }
    Neutron_ovn_vpn_agent_config<||> ~> Service['neutron-vpnaas-ovn-vpn-agent']
  }
}
