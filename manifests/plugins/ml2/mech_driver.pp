#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# neutron::plugins::ml2::mech_driver used by neutron::plugins::ml2
#
# === Parameters:
#
# [*supported_pci_vendor_devs*]
#   (required) Supported PCI vendor devices, defined by vendor_id:product_id according
#   to the PCI ID Repository. Default enables support for Intel and Mellanox SR-IOV capable NICs
#
# DEPRECATED PARAMETERS
#
# [*ovs_vnic_type_blacklist*]
#  (optional) list of VNIC types for which support in Neutron is
#  administratively prohibited by the OVS mechanism driver
#
# [*sriov_vnic_type_blacklist*]
#  (optional) list of VNIC types for which support in Neutron is
#  administratively prohibited by the SR-IOV mechanism driver
#
define neutron::plugins::ml2::mech_driver (
  $supported_pci_vendor_devs,
  # DEPRECATED PARAMETERS
  $ovs_vnic_type_blacklist      = undef,
  $sriov_vnic_type_blacklist    = undef,
){

  include neutron::deps

  if ($name == 'sriovnicswitch') {
    neutron_plugin_sriov {
      'ml2_sriov/supported_pci_vendor_devs': value => join(any2array($supported_pci_vendor_devs), ',');
    }
    case $::osfamily {
      'RedHat': {
        file { '/etc/neutron/conf.d/neutron-server/ml2_conf_sriov.conf':
          ensure => link,
          target => '/etc/neutron/plugins/ml2/ml2_conf_sriov.ini',
        }
      }
      /^(Debian|Ubuntu)$/: {
          file_line { 'DAEMON_ARGS':
            path => '/etc/default/neutron-server',
            line => 'DAEMON_ARGS="$DAEMON_ARGS --config-file /etc/neutron/plugins/ml2/ml2_conf_sriov.ini"',
          }
      }
      default: {
        fail("Unsupported osfamily ${::osfamily}")
      }
    }
  }

  if ($ovs_vnic_type_blacklist != undef) {
    warning('neutron::plugins::ml2::mech_driver::ovs_vnic_type_blacklist has been \
deperecated. Use neutron::plugins::ml2::ovs_driver class')
    class { 'neutron::plugins::ml2::ovs_driver':
      vnic_type_blacklist => $ovs_vnic_type_blacklist
    }
  }

  if ($sriov_vnic_type_blacklist != undef) {
    warning('neutron::plugins::ml2::mech_driver::sriov_vnic_type_blacklist has been \
deperecated. Use neutron::plugins::ml2::sriov_driver class')
    class { 'neutron::plugins::ml2::sriov_vnic_type_blacklist':
      vnic_type_blacklist => $sriov_vnic_type_blacklist
    }
  }
}
