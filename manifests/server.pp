class quantum::server (
  $keystone_password,
  $log_file        = "/var/log/quantum/server.log",
  $auth_type       = "keystone",
  $auth_host       = "localhost",
  $auth_port       = "35357",
# $auth_uri        = "http://localhost:5000",
  $keystone_tenant = "services",
  $keystone_user   = "quantum",
  $package_ensure  = 'present'
) inherits quantum {
  require 'keystone::python'

  Package["quantum-server"] -> Quantum_api_config<||>
  Package["quantum-server"] -> Quantum_config<||>
  Quantum_config<||> ~> Service["quantum-server"]
  Quantum_api_config<||> ~> Service["quantum-server"]

  quantum_config {
    "DEFAULT/log_file":  value => $log_file
  }

  quantum_api_config {
    "filter:authtoken/auth_host": value => $auth_host;
    "filter:authtoken/auth_port": value => $auth_port;
    "filter:authtoken/auth_uri": value => $auth_uri;
    "filter:authtoken/admin_tenant_name": value => $keystone_tenant;
    "filter:authtoken/admin_user": value => $keystone_user;
    "filter:authtoken/admin_password": value => $keystone_password;
  }

  if $enabled {
    $service_ensure = "running"
  } else {
    $service_ensure = "stopped"
  }

  package {"quantum-server":
    name   => $::quantum::params::server_package,
    ensure => $package_ensure
  }

  service {"quantum-server":
    name       => $::quantum::params::server_service,
    ensure     => $service_ensure,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true
  }
}
