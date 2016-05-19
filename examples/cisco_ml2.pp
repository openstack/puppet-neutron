class { '::neutron':
  enabled         => true,
  bind_host       => '127.0.0.1',
  rabbit_host     => '127.0.0.1',
  rabbit_user     => 'neutron',
  rabbit_password => 'rabbit_secret',
  debug           => true,
}

class { '::neutron::server':
  auth_uri      => 'http://127.0.0.1:5000',
  auth_password => 'keystone_secret',
}

class { '::neutron::plugins::ml2':
  type_drivers         => ['vlan', 'nexus_vxlan'],
  tenant_network_types => ['nexus_vxlan'],
  network_vlan_ranges  => ['physnet:2000:2020'],
  mechanism_drivers    => ['openvswitch', 'cisco_ucsm', 'cisco_nexus'],
}

class {'::neutron::plugins::ml2::cisco::ucsm':
  ucsm_ip        => '127.0.0.1',
  ucsm_username  => 'admin',
  ucsm_password  => 'password',
  ucsm_host_list => 'host1:profile1, host2:profile2',
}

class {'::neutron::plugins::ml2::cisco::nexus':
  managed_physical_network => 'physnet',
  nexus_config             => {
    'n9372-1' => {
      'username'     => 'admin',
      'password'     => 'password',
      'ssh_port'     => 22,
      'ip_address'   => '127.0.0.1',
      'nve_src_intf' => 1,
      'physnet'      => 'physnet',
      'servers'      => {
        'control1' => {
          'ports' => 'ethernet:1/1',
        },
        'control2' => {
          'ports' => 'ethernet:1/2',
        },
      }
    },
    'n9372-2' => {
      'username'     => 'admin',
      'password'     => 'password',
      'ssh_port'     => 22,
      'ip_address'   => '127.0.0.2',
      'nve_src_intf' => 1,
      'physnet'      => 'physnet',
      'servers'      => {
        'compute1' => {
          'ports' => 'ethernet:1/1',
        },
        'compute2' => {
          'ports' => 'ethernet:1/2',
        },
      }
    }
  },
}

class {'::neutron::plugins::ml2::cisco::type_nexus_vxlan':
  vni_ranges   => '20000:22000',
  mcast_ranges => '224.0.0.1:224.0.0.4',
}

