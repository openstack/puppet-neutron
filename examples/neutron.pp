### Cloud Controller:

# General Neutron stuff
# Configures everything in neutron.conf
class { 'neutron':
  verbose               => true,
  allow_overlapping_ips => true,
  rabbit_password       => 'password',
  rabbit_user           => 'guest',
  rabbit_host           => 'localhost',
}

# The API server talks to keystone for authorisation
class { 'neutron::server':
  keystone_password => 'password',
  connection        => 'mysql://neutron:password@192.168.1.1/neutron',
}

# Various agents
class { 'neutron::agents::dhcp': }
class { 'neutron::agents::l3': }
class { 'neutron::agents::lbaas': }

# This plugin configures Neutron for OVS on the server
# Agent
class { 'neutron::agents::ovs':
  local_ip         => '192.168.1.1',
  enable_tunneling => true,
}

# Plugin
class { 'neutron::plugins::ovs':
  tenant_network_type => 'gre',
}


### Compute Nodes:
# Generally, any machine with a neutron element running on it talks
# over Rabbit and needs to know if overlapping IPs (namespaces) are in use
class { 'neutron':
  allow_overlapping_ips => true,
  rabbit_password       => 'password',
  rabbit_user           => 'guest',
  rabbit_host           => 'localhost',
}

# The agent/plugin combo also needs installed on clients
# Agent
class { 'neutron::agents::ovs':
  local_ip         => '192.168.1.11',
  enable_tunneling => true,
}

# Plugin
class { 'neutron::plugins::ovs':
  tenant_network_type => 'gre',
}
