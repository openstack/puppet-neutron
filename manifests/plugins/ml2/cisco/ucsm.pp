#
# Configure the Mech Driver for Cisco UCSM plugin
# More info available here:
# http://networking-cisco.readthedocs.io
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
# [*ucsm_https_verify*]
#   (optional) Set to False to turn off SSL certificate checking
#   while connecting to UCS Manager.
#   Defaults to True.
#
# [*sp_template_list*]
#   (optional) This configuration needs to be provided when
#   UCS Servers are controlled by Service Profile Templates.
#   Example:
#   sp_template_list = SP_Template1_path:SP_Template1:S1,S2
#                      SP_Template2_path:SP_Template2:S3,S4,S5
#
# [*vnic_template_list*]
#   (optional) This configuration needs to be provided when vNICs
#   on UCS Servers are controlled by vNIC Templates.
#   Example:
#   vnic_template_list = physnet1:vnic_template_path1:vt1
#                        physnet2:vnic_template_path2:vt2
#
class neutron::plugins::ml2::cisco::ucsm (
  $ucsm_ip,
  $ucsm_username,
  $ucsm_password,
  $ucsm_host_list,
  $sp_template_list,
  $vnic_template_list,
  $supported_pci_devs = $::os_service_default,
  $ucsm_https_verify = $::os_service_default,
) {

  include ::neutron::deps
  include ::neutron::plugins::ml2::cisco

  neutron_plugin_ml2 {
    'ml2_cisco_ucsm/ucsm_ip'            : value => $ucsm_ip;
    'ml2_cisco_ucsm/ucsm_username'      : value => $ucsm_username;
    'ml2_cisco_ucsm/ucsm_password'      : value => $ucsm_password, secret => true;
    'ml2_cisco_ucsm/ucsm_host_list'     : value => $ucsm_host_list;
    'ml2_cisco_ucsm/sp_template_list'   : value => $sp_template_list;
    'ml2_cisco_ucsm/vnic_template_list' : value => $vnic_template_list;
    'ml2_cisco_ucsm/supported_pci_devs' : value => $supported_pci_devs;
    'ml2_cisco_ucsm/ucsm_https_verify'  : value => $ucsm_https_verify;
  }
}

