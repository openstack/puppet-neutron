# Example of manifest to deploy Neutron API in WSGI with Apache
class { '::neutron':
  allow_overlapping_ips => true,
  rabbit_password       => 'password',
  rabbit_user           => 'guest',
  rabbit_host           => 'localhost',
}

class { '::neutron::server':
  auth_password       => 'password',
  database_connection => 'mysql://neutron:password@192.168.1.1/neutron',
  service_name        => 'httpd',
}
include ::apache
class { '::neutron::wsgi::apache':
  ssl => false,
}
