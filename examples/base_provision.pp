#
# This manifest is intended to demonstrate how to provision the
# resources necessary to boot a vm with network connectivity provided
# by quantum.
#
# Note that a quantum_router resouce must declare a dependency on the
# first subnet of the gateway network.  Other dependencies for the
# resources used in this example can be automatically determined.
#

keystone_tenant { 'admin':
  ensure => present,
}

quantum_network { 'public':
  ensure          => present,
  router_external => 'True',
  tenant_name     => 'admin',
}

quantum_subnet { 'public_subnet':
  ensure       => 'present',
  cidr         => '172.24.4.224/28',
  network_name => 'public',
  tenant_name  => 'admin',
}

keystone_tenant { 'demo':
  ensure => present,
}

quantum_network { 'private':
  ensure          => present,
  tenant_name     => 'demo',
}

quantum_subnet { 'private_subnet':
  ensure       => present,
  cidr         => '10.0.0.0/24',
  network_name => 'private',
  tenant_name  => 'demo',
}

# Tenant-private router - assumes network namespace isolation
quantum_router { 'demo_router':
  ensure               => present,
  tenant_name          => 'demo',
  gateway_network_name => 'public',
  require              => Quantum_subnet['public_subnet'],
}

quantum_router_interface { 'demo_router:private_subnet':
  ensure => present,
}
