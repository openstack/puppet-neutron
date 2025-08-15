### Cloud Controller:

# General Neutron stuff
# Configures everything in neutron.conf
class { 'neutron':
  default_transport_url => 'rabbit://guest:password@localhost:5672/neutron',
  service_plugins       => ['metering'],
}

# The API server talks to keystone for authorisation
class { 'neutron::server':
  auth_password       => 'password',
  database_connection => 'mysql+pymysql://neutron:password@192.168.1.1/neutron',
}

# Configure nova notifications system
class { 'neutron::server::notifications':
  tenant_name => 'admin',
  password    => 'secrete',
}

# Various agents
class { 'neutron::agents::dhcp': }
class { 'neutron::agents::l3': }
class { 'neutron::agents::vpnaas': }
class { 'neutron::agents::metering': }

# This plugin configures Neutron for OVS on the server
# Agent
class { 'neutron::agents::ml2::ovs':
  local_ip     => '192.168.1.1',
  tunnel_types => ['vxlan'],
}

# ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
class { 'neutron::plugins::ml2':
  type_drivers         => ['vxlan'],
  tenant_network_types => ['vxlan'],
  vxlan_group          => '239.1.1.1',
  mechanism_drivers    => ['openvswitch'],
  vni_ranges           => ['0:300'],
}

### Compute Nodes:
# Generally, any machine with a neutron element running on it talks
# over Rabbit and needs to know if overlapping IPs (namespaces) are in use
class { 'neutron':
  default_transport_url => 'rabbit://guest:password@localhost:5672/neutron',
}

# The agent/plugin combo also needs installed on clients
# Agent
class { 'neutron::agents::ml2::ovs':
  local_ip     => '192.168.1.11',
  tunnel_types => ['vxlan'],
}
