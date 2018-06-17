# Example of manifest to deploy Neutron API in WSGI with Apache
class { '::neutron':
  allow_overlapping_ips => true,
  default_transport_url => 'rabbit://guest:password@localhost:5672/neutron',
}

class { '::neutron::server':
  auth_password       => 'password',
  database_connection => 'mysql+pymysql://neutron:password@192.168.1.1/neutron',
  service_name        => 'httpd',
}
include ::apache
class { '::neutron::wsgi::apache':
  ssl => false,
}
