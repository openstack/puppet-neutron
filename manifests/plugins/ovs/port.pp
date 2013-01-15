define quantum::plugins::ovs::port {
  $mapping = split($name, ":")
  vswitch::port {$mapping[1]:
    ensure => present,
    bridge => $mapping[0]
  }
}

