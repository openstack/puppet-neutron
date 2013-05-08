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

keystone_tenant { 'demo':
  ensure => present,
}

quantum_network { 'private':
  ensure          => present,
  tenant_name     => 'demo',
}
