### Servers:

# Generally, any machine with a quantum element running on it talks over Rabbit and needs to know if overlapping IPs (namespaces) are in use
class { quantum:
  $allow_overlapping_ips  = 'False',

  $rabbit_password => 'password',
  $rabbit_host            = 'localhost',
  $rabbit_port            = '5672',
  $rabbit_user            = 'guest',
  $rabbit_virtual_host    = '/'
}

# The API server talks to keystone for authorisation
class { quantum::server:
  $auth_password => 'password', # with keystone,
  $auth_host        = 'localhost',
  $auth_tenant      = 'services',
  $auth_user        = 'quantum'
}

# The OVS plugin has its own DB and implements network sharing strategy
# It must also know what 'networks' the agent nodes share between them
class { quantum::plugins::ovs:
  $sql_connection       = 'sqlite://quantum@localhost/quantum',
  $tenant_network_type  = 'gre',
  $network_vlan_ranges  = 'physnet1',
}


### Clients:
# Generally, any machine with a quantum element running on it talks over Rabbit and needs to know if overlapping IPs (namespaces) are in use
class { quantum:
  $allow_overlapping_ips  = 'False',

  $rabbit_password => 'password',
  $rabbit_host            = 'localhost',
  $rabbit_port            = '5672',
  $rabbit_user            = 'guest',
  $rabbit_virtual_host    = '/'
}

# With OVS networks, the server has all the smarts and the clients need only have the
# OVS agent installed, which will get information from the server and do something useful
# with it
class { quantum::agents::ovs:
  $bridge_uplinks       = ['br-virtual:eth1'], # Interfaces in each bridge
  $bridge_mappings      = ['physnet1:br-virtual'], # Network name for bridge (see vlan ranges above)
  $enable_tunneling     = true, # if GRE above,
  $local_ip             = '1.2.3.4', # a local IP address to this machine - needed if GRE
}
