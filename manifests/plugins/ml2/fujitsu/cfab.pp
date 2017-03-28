#
# Configure the Fujitsu neutron ML2 plugin for C-Fabric
#
# === Parameters
#
# [*address*]
# (required) The address of the C-Fabric to telnet to.
# Example: 192.168.0.1
#
# [*username*]
# (optional) The C-Fabric username to use.
# Example: username
#
# [*password*]
# (optional) The C-Fabric password to use.
# Example: password
#
# [*physical_networks*]
# (optional) physical_network names and corresponding vfab ids.
# Example: physnet1:1,physnet2:2
# Defaults to ''
#
# [*share_pprofile*]
# (optional) Whether to share a C-Fabric pprofile among Neutron ports using the
# same VLAN ID.
# Example: true
# Defaults to false
#
# [*pprofile_prefix*]
# (optional) The prefix string for pprofile name.
# Example: neutron-
# Defaults to ''
#
# [*save_config*]
# (optional) Whether to save configuration.
# Example: true
# Defaults to true
#
class neutron::plugins::ml2::fujitsu::cfab (
  $address,
  $username,
  $password,
  $physical_networks = '',
  $share_pprofile    = false,
  $pprofile_prefix   = '',
  $save_config       = true,
)
{
  require ::neutron::plugins::ml2

  neutron_plugin_ml2 {
    'fujitsu_cfab/address'           : value => $address;
    'fujitsu_cfab/username'          : value => $username;
    'fujitsu_cfab/password'          : value => $password, secret => true;
    'fujitsu_cfab/physical_networks' : value => join(any2array($physical_networks), ',');
    'fujitsu_cfab/share_pprofile'    : value => $share_pprofile;
    'fujitsu_cfab/pprofile_prefix'   : value => $pprofile_prefix;
    'fujitsu_cfab/save_config'       : value => $save_config;
  }
}
