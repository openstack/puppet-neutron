class {"quantum::server":}
class {"quantum::plugins::ovs": 
  bridge_uplinks => "br-virtual:eth1",
  server         => true
}
