#
# This manifest is intended to demonstrate the 'transform_to' argument
# for converting the name of a Neutron router to its UUID for
# inclusion in l3-agent.ini
#
# This manifest extends the one shown in base_provision.pp
#

class { '::neutron':
  allow_overlapping_ips => true,
  rabbit_password       => 'password',
  rabbit_user           => 'guest',
  rabbit_host           => 'localhost',
  service_plugins       => ['router']
}

class { '::neutron::server':
  auth_password       => 'password',
  database_connection => 'mysql://neutron:password@192.168.1.1/neutron',
}

# configure l3-agent to use the new router by name
class { '::neutron::agents::l3':
  enabled        => true,
  use_namespaces => false,
  require        => Neutron_router['demo_router'],
}

neutron_l3_agent_config {
  'DEFAULT/router_id':  value => 'demo_router', transform_to => 'uuid';
}
