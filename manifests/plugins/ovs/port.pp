#
define neutron::plugins::ovs::port {

  include ::neutron::deps

  $mapping = split($name, ':')
  vs_port {$mapping[1]:
    ensure => present,
    bridge => $mapping[0]
  }
}

