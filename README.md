Puppet module for OpenStack Quantum
===================================

This is an extremely basic puppet module for quantum. Right now it only supports Open vSwitch. Some of the Open vSwitch functionality should probably be moved to its own module. 

At the moment, this has only been tested on an all-in-one installation, although this module has been created with a multi-node installation in mind.

How to Use
----------
Set the `network_manager` to Quantum in your OpenStack class:

```puppet
class { 'openstack::all':
  ...
  network_manager      => 'nova.network.quantum.manager.QuantumManager',
  ...
}
```

Next, configure Quantum:

```puppet
# This class goes on the controller
class { 'quantum': }
# This plugin class also goes on the controller
class { 'quantum::plugins::openvswitch::controller': 
  db_pass => 'password',
}
# This goes on the compute node
# If using multiple hosts, the above two classes
# do not go on compute nodes
class { 'quantum::plugins::openvswitch::compute':
  db_pass => 'password',
  private_interface => 'eth1',
}
```

Notes
-----
* If you are upgrading to Quantum, you will have to migrate your current OpenStack networks. Please see the Quantum / Open vSwitch docs for this.
* If you don't want to migrate, just drop your nova database (or nova.networks table at the minimum) and re-run the manifest.
* Quantum does not support multi_host networking.
* This will set up a bridge called `br-int`. It works pretty similar to Linux's standard bridging but it also has built-in vlan support. By using this default Quantum configuration, you are basically emulating VlanManager.
