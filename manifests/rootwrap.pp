# == Class: neutron::rootwrap
# DEPRECATED !!
# Manages the neutron rootwrap.conf file on systems
#
# === Parameters:
#
class neutron::rootwrap (
) {

  include neutron::deps

  warning('The neutron::rootwrap class is deprecated.')
}
