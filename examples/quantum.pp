class {"quantum::server":}
class {"quantum::plugins::ovs": 
  bridge_uplinks => "default:eth1",
  server         => true
}
