class quantum (
  $rabbit_password,
  $verbose          = "False",
  $debug            = "False",

  $bind_host            = "0.0.0.0",
  $bind_port            = "9696",
  $sql_connection       = "sqlite:///var/lib/quantum/quantum.sqlite",
  $rabbit_host          = "localhost",
  $rabbit_port          = "5672",
  $rabbit_user          = "guest",
  $rabbit_virtual_host  = "/",

  $control_exchange     = "quantum",

  $core_plugin            = "quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2",
  $mac_generation_retries = 16,
  $dhcp_lease_duration    = 120,
  $auth_strategy          = 'keystone',
  $enabled                = true,
  $package_ensure         = 'present'
) {
  include quantum::params

  validate_re($sql_connection, '(sqlite|mysql|posgres):\/\/(\S+:\S+@\S+\/\S+)?')

  Package['quantum'] -> Quantum_config<||>

  if ($sql_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    ensure_resource( 'package', 'python-mysqldb', {'ensure' => 'present'})
  } elsif ($sql_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {
    ensure_resource( 'package', 'python-psycopg2', {'ensure' => 'present'})
  } elsif($sql_connection =~ /sqlite:\/\//) {
    ensure_resource( 'package', 'python-pysqlite2', {'ensure' => 'present'})
  } else {
    fail("Invalid db connection ${sql_connection}")
  }

  file {"/etc/quantum":
    ensure  => directory,
    owner   => "quantum",
    group   => "root",
    mode    => 770,
    require => Package["quantum"]
  }

  package {"quantum":
    name   => $::quantum::params::package_name,
    ensure => $package_ensure
  }

  quantum_config {
    "DEFAULT/verbose":                value => $verbose;
    "DEFAULT/debug":                  value => $debug;

    "DEFAULT/bind_host":              value => $bind_host;
    "DEFAULT/bind_port":              value => $bind_port;

    "DEFAULT/sql_connection":         value => $sql_connection;

    "DEFAULT/auth_strategy":          value => $auth_strategy;

    "DEFAULT/rabbit_host":            value => $rabbit_host;
    "DEFAULT/rabbit_port":            value => $rabbit_port;
    "DEFAULT/rabbit_userid":          value => $rabbit_user;
    "DEFAULT/rabbit_password":        value => $rabbit_password;
    "DEFAULT/rabbit_virtual_host":    value => $rabbit_virtual_host;

    "DEFAULT/control_exchange":       value => $control_exchange;

    "DEFAULT/core_plugin":            value => $core_plugin;
    "DEFAULT/mac_generation_retries": value => $mac_generation_retries;
    "DEFAULT/dhcp_lease_duration":    value => $dhcp_lease_duration;
  }
}
