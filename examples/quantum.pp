### Cloud Controller:

# General Quantum stuff
# Configures everything in quantum.conf
class { 'quantum':
  verbose               => true,
  allow_overlapping_ips => true,
  rabbit_password       => 'password',
  rabbit_user           => 'guest',
  rabbit_host           => 'localhost',
}

# The API server talks to keystone for authorisation
class { 'quantum::server':
  keystone_password => 'password',
}

# Various agents
class { 'quantum::agents::dhcp': }
class { 'quantum::agents::l3': }
class { 'quantum::agents::lbaas': }

# This plugin configures Quantum for OVS on the server
# Agent
class { 'quantum::agents::ovs':
  local_ip         => '192.168.1.1',
  enable_tunneling => true,
}

# Plugin
class { 'quantum::plugins::ovs':
  sql_connection      => 'mysql://quantum:password@localhost/quantum',
  tenant_network_type => 'gre',
}


### Compute Nodes:
# Generally, any machine with a quantum element running on it talks
# over Rabbit and needs to know if overlapping IPs (namespaces) are in use
class { 'quantum':
  allow_overlapping_ips => true,
  rabbit_password       => 'password',
  rabbit_user           => 'guest',
  rabbit_host           => 'localhost',
}

# The agent/plugin combo also needs installed on clients
# Agent
class { 'quantum::agents::ovs':
  local_ip         => '192.168.1.11',
  enable_tunneling => true,
}

# Plugin
class { 'quantum::plugins::ovs':
  sql_connection      => 'mysql://quantum:password@192.168.1.1/quantum',
  tenant_network_type => 'gre',
}
