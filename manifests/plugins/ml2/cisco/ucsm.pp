#
# Configure the Mech Driver for Cisco UCSM plugin
# More info available here:
# http://docwiki.cisco.com/wiki/UCS_Mechanism_Driver_for_ML2_Plugin:_Kilo
#
# === Parameters
#
# [*ucsm_ip*]
#   (required) IP address of the Cisco UCS Manager
#
# [*ucsm_username*]
#   (required) Username to connect to the UCS Manager
#
# [*ucsm_password*]
#   (required) Password to connect to the UCS Manager
#
# [*ucsm_host_list*]
#   (required)
#   Hostname to Service profile mapping for UCSM-controlled compute hosts
#   Example:
#   Hostname1:Serviceprofile1, Hostname2:Serviceprofile2
#
# [*supported_pci_devs*]
#   (optional) SR-IOV and VM-FEX vendors supported by this plugin
#   xxxx:yyyy represents vendor_id:product_id
#   Defaults to $::os_service_default
#   Example:
#   [ '2222:3333', '4444:5555' ]
#

class neutron::plugins::ml2::cisco::ucsm (
  $ucsm_ip,
  $ucsm_username,
  $ucsm_password,
  $ucsm_host_list,
  $supported_pci_devs = $::os_service_default,
) {

  include ::neutron::deps
  include ::neutron::plugins::ml2::cisco

  neutron_plugin_ml2 {
    'ml2_cisco_ucsm/ucsm_ip'            : value => $ucsm_ip;
    'ml2_cisco_ucsm/ucsm_username'      : value => $ucsm_username;
    'ml2_cisco_ucsm/ucsm_password'      : value => $ucsm_password;
    'ml2_cisco_ucsm/ucsm_host_list'     : value => $ucsm_host_list;
    'ml2_cisco_ucsm/supported_pci_devs' : value => $supported_pci_devs;
  }
}

