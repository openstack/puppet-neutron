define quantum::plugins::ovs::bridge {
  $mapping = split($name, ":")
  $bridge = $mapping[1]

  vswitch::bridge {$bridge:
    ensure       => present,
    external_ids => "bridge-id=${bridge}"
  }
}

