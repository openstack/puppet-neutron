#
# This manifest is intended to demonstrate how to provision the
# resources necessary to boot a vm with network connectivity provided
# by quantum.
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
