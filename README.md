neutron
===================================

#### Table of Contents

1. [Overview - What is the neutron module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - Tha basics of getting started with neutron.](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing.](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The neutron module is a part of [OpenStack](https://github.com/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects as part of the core software. The module itself is used to flexibly configure and manage the network service for OpenStack.

Module Description
------------------

The neutron module is an attempt to make Puppet capable of managing the entirety of neutron. This includes manifests to provision such things as keystone endpoints, RPC configurations specific to neutron, database connections, and network driver plugins. Types are shipped as part of the neutron module to assist in manipulation of the OpenStack configuration files.

This module is tested in combination with other modules needed to build and leverage an entire OpenStack installation.

Setup
-----

**What the neutron module affects:**

* [Neutron](https://wiki.openstack.org/wiki/Neutron), the network service for OpenStack.

### Installing neutron

    puppet module install openstack/neutron

### Beginning with neutron

To utilize the neutron module's functionality you will need to declare multiple resources. The following example displays the setting up of an Open vSwitch neutron installation. This is not an exhaustive list of all the components needed. We recommend that you consult and understand the [core openstack](http://docs.openstack.org) documentation to assist you in understanding the available deployment options.

```puppet
# enable the neutron service
class { '::neutron':
    enabled         => true,
    bind_host       => '127.0.0.1',
    rabbit_host     => '127.0.0.1',
    rabbit_user     => 'neutron',
    rabbit_password => 'rabbit_secret',
    debug           => false,
}

# configure authentication
class { 'neutron::server':
    auth_password   => 'keystone_neutron_secret',
    sql_connection  => 'mysql://neutron:neutron_sql_secret@127.0.0.1/neutron?charset=utf8',
}

# ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
class { '::neutron::plugins::ml2':
  type_drivers         => ['vxlan'],
  tenant_network_types => ['vxlan'],
  vxlan_group          => '239.1.1.1',
  mechanism_drivers    => ['openvswitch'],
  vni_ranges           => ['1:300']
}
```

Other neutron network drivers include:

* dhcp,
* metadata,
* and l3.

Nova will also need to be configured to connect to the neutron service. Setting up the `nova::network::neutron` class sets
the `network_api_class` parameter in nova to use neutron instead of nova-network.

```puppet
class { 'nova::network::neutron':
  neutron_password  => 'neutron_admin_secret',
}
```


The `examples` directory also provides a quick tutorial on how to use this module.

Implementation
--------------

### neutron

neutron is a combination of Puppet manifest and ruby code to deliver configuration and extra functionality through *types* and *providers*.

### Types

#### neutron_config

The `neutron_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/neutron/neutron.conf` file.

```puppet
neutron_config { 'DEFAULT/core_plugin' :
  value => openvswitch,
}
```

This will write `core_plugin=openvswitch` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `neutron.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`


Limitations
-----------

This module supports the following neutron plugins:

* Open vSwitch with ML2
* linuxbridge with ML2
* Arista with ML2
* cisco-neutron with and without ML2
* NVP
* PLUMgrid

The following platforms are supported:

* Ubuntu 12.04 (Precise)
* Debian (Wheezy)
* RHEL 6
* Fedora 18

Beaker-Rspec
------------

This module has beaker-rspec tests

To run:

```shell
bundle install
bundle exec rspec spec/acceptance
```

Development
-----------

The puppet-openstack modules follow the OpenStack development model. Developer documentation for the entire puppet-openstack project is at:

* http://docs.openstack.org/developer/puppet-openstack-guide/

Contributors
------------
The github [contributor graph](https://github.com/openstack/puppet-neutron/graphs/contributors).
