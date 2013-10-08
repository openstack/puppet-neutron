quantum
===================================

#### Table of Contents

1. [Overview - What is the quantum module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - Tha basics of getting started with quantum.](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing.](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------

The quantum module is a part of [Stackforge](https://github.com/stackforge), an effort by the Openstack infrastructure team to provide continuous integration testing and code review for Openstack and Openstack community projects not part of the core software. The module itself is used to flexibly configure and manage the newtork service for Openstack.

Module Description
------------------

The quantum module is an attempt to make Puppet capable of managing the entirety of quantum. This includes manifests to provision such things as keystone endpoints, RPC configurations specific to quantum, database connections, and network driver plugins. Types are shipped as part of the quantum module to assist in manipulation of the Openstack configuration files.

This module is tested in combination with other modules needed to build and leverage an entire Openstack installation. These modules can be found, all pulled together in the [openstack module](https://github.com/stackforge/puppet-openstack).

Setup
-----

**What the quantum module affects:**

* [Quantum](https://wiki.openstack.org/wiki/Quantum), the network service for Openstack.

### Installing quantum

    puppet module install puppetlabs/quantum

### Beginning with quantum

To utilize the quantum module's functionality you will need to declare multiple resources. The following is a modified excerpt from the [openstack module](httpd://github.com/stackforge/puppet-openstack). It provides an example of setting up an Open vSwitch quantum installation. This is not an exhaustive list of all the components needed. We recommend that you consult and understand the [openstack module](https://github.com/stackforge/puppet-openstack) and the [core openstack](http://docs.openstack.org) documentation to assist you in understanding the available deployment options.

```puppet
# enable the quantum service
class { '::quantum':
    enabled         => true,
    bind_host       => '127.0.0.1',
    rabbit_host     => '127.0.0.1',
    rabbit_user     => 'quantum',
    rabbit_password => 'rabbit_secret',
    verbose         => false,
    debug           => false,
}

# configure authentication
class { 'quantum::server':
    auth_host       => '127.0.0.1', # the keystone host address
    auth_password   => 'keystone_quantum_secret',
}

# enable the Open VSwitch plugin server
class { 'quantum::plugins::ovs':
    sql_connection      => 'mysql://quantum:quantum_sql_secret@127.0.0.1/quantum?charset=utf8',
    tenant_network_type => 'gre',
    network_vlan_ranges => 'physnet:1000:2000',
}
```

Other quantum network drivers include:

* dhcp,
* metadata,
* and l3.

Nova will also need to be configured to connect to the quantum service. Setting up the `nova::network::quantum` class sets
the `network_api_class` parameter in nova to use quantum instead of nova-network.

```puppet
class { 'nova::network::quantum':
  quantum_admin_password  => 'quantum_admin_secret',
}
```


The `examples` directory also provides a quick tutorial on how to use this module.

Implementation
--------------

### quantum

quantum is a combination of Puppet manifest and ruby code to deliver configuration and extra functionality through *types* and *providers*.


Limitations
-----------

This module supports the following quantum plugins:

* Open vSwitch
* linuxbridge
* cisco-quantum

The following platforms are supported:

* Ubuntu 12.04 (Precise)
* Debian (Wheezy)
* RHEL 6

Development
-----------

The puppet-openstack modules follow the Openstack development model. Developer documentation for the entire puppet-openstack project is at:

* https://wiki.openstack.org/wiki/Puppet-openstack#Developerdocumentation

Contributors
------------
The github [contributor graph](https://github.com/stackforge/puppet-quantum/graphs/contributors).

Release Notes
-------------

**2.2.0**

* Improved documentation.
* Added syslog support.
* Added quantum-plugin-cisco package resource.
* Various lint and bug fixes.
