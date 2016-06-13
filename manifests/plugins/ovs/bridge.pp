#
define neutron::plugins::ovs::bridge {

  include ::neutron::deps

  $mapping = split($name, ':')
  $bridge = $mapping[1]

  vs_bridge {$bridge:
    ensure       => present,
    external_ids => "bridge-id=${bridge}"
  }
}

