## 8.0.0 and beyond

From 8.0.0 release and beyond, release notes are published on
[docs.openstack.org](http://docs.openstack.org/releasenotes/puppet-neutron/).

##2015-11-25 - 7.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Liberty.

####Backwards-incompatible changes
- change section name for AMQP qpid parameters
- remove deprcated mysql options
- delete namespaces by default
- filename change for config-dir for ml2 cisco nexus mech driver
- unset deprecated parameter use_namespaces by default
- drop neutron_plugin_ovs type/provider

####Features
- add driver option for metering agent
- split SR-IOV configuration file into driver and agent pieces
- disable third-party software management
- jumbo frames between instances
- remove POSIX users, groups, and file modes
- add support for RabbitMQ connection heartbeat
- keystone/auth: make service description configurable
- add tag to package and service resources
- allow neutron-dhcp-agent broadcast reply
- add neutron::db::sync and neutron::db
- add an ability to manage use_stderr parameter
- reflect provider change in puppet-openstacklib
- make vswitch optional for ovs agent configuration
- allow greater flexibility in the kind of parameter passed to ml2.pp
- deprecate nova_admin_* options
- drop nova_admin_tenant_id_setter
- db: Use postgresql lib class for psycopg package
- allow customization of db sync command line
- support for Nuage Neutron plugin
- suport for Big Switch ML2 plugin
- add an ability to set up drop_flows_on_start option
- use json output instead plain-text
- use json instead of regexp to parse subnet data
- simplify rpc_backend parameter
- add support for prevent_arp_spoofing option
- add support for rpc_response_timeout option
- remove use of template based config from cisco ml2 nexus plugin
- update Cisco ML2 configuration
- make package change run the db_sync
- accommodate for VPNaaS package name change in RDO

####Bugfixes
- rely on autorequire for config resource ordering
- make sure Neutron_config is applied before Neutron_network
- make sure Nova_admin_tenant_id_setter is executed after Keystone_endpoint
- add workaround for v2 tenant names
- swap Facter[].value with Facter.value()
- dbsync should only notify services that use the db
- map allocation_pool property to set
- restart Neutron agents if packages are updated
- remove unecessary constraint between Package and Config resource
- fix 'shared' parameter check in neutron_network provider

####Maintenance
- acceptance: enable debug & verbosity for OpenStack logs
- remove unused variable in params.pp
- initial msync run for all Puppet OpenStack modules
- lint: Add and fix missing parameter documentation
- try to use zuul-cloner to prepare fixtures
- remove class_parameter_defaults puppet-lint check
- add test coverage for neutron::db::mysql
- fix rspec 3.x syntax
- acceptance: use common bits from puppet-openstack-integration
- fix unit tests against Puppet 4.3.0
- acceptance: enable loadbalancer service_plugin
- acceptance: test OVS bridge listing

##2015-10-10 - 6.1.0
### Summary

This is a feature and bugfix release in the Kilo series.

The ml2_sriov/supported_pci_vendor_devs parameter (in ml2 mech driver) was
previously never applied, this bug was fixed by Sebastien.

The neutron_agent_linuxbridge ini file configuration is different on Ubuntu.
Colleen has fixed our manifest in order to reflect this packaging change.

####Features
- Allow deployment when DVR is enabled and L2 pop and tunneling are disabled
- N1Kv: Adding nexus1000v puppet class
- N1Kv:Adding params for IPv6 communication with VSM

####Bugfixes
- Fix neutron_agent_linuxbridge file path
- ml2: Fix typo with ml2_srvio/supported_pci_vendor_devs param.

####Maintenance
- acceptance: checkout stable/kilo puppet modules

##2015-07-08 - 6.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Kilo.

####Backwards-incompatible changes
- Remove deprecated parameters
- Drop OVS & LB monolitic plugins
- Use libreswan on fedora
- Move rabbit/kombu settings to oslo_messaging_rabbit section
- FWaaS: update packaging for Debian & Ubuntu
- Don't specify a nova region by default
- Do not create tun and int bridges manually

####Features
- Puppet 4.x support
- Refactorise Keystone resources management
- Add 'state_path' and 'lock_path' to neutron class
- Add service_name parameter to neutron::server class
- DB: Added postgresql backend using openstacklib helper
- Subscribe neutron db sync to db connection setting
- Ensure DB is provisioned before db-sync
- Add support for identity_uri
- Notify the ovs-agent service if the config changes
- Add portdb and fastpath_flood to n1kv.conf
- Add fwaas package for Kilo in Red Hat platforms
- Add memcache_servers parameter to base neutron class
- Add MidoNet plugin support
- Add PLUMgrid plugin support
- Add OpenContrail plugin support
- Tag all neutron packages
- Allow to configure Nova metadata protocol
- Configure OVS mechanism agent configs in its config file
- Don't manage chmod for /etc/neutron and neutron.conf
- Introduce public_url, internal_url and admin_url
- Allow customization of dhcp_domain setting
- Add manage_service parameter to all agents
- Add ability to specify auth_region

####Bugfixes
- Fix l3 agent network_device_mtu deprecation
- Set allow_automatic_l3agent_failover in neutron.conf instead of l3_agent.ini
- Fix parsing of network gateway id for router

####Maintenance
- Acceptance tests with Beaker
- Fix spec tests for RSpec 3.x and Puppet 4.x

##2015-06-17 - 5.1.0
###Summary

This is a feature and bugfix release in the Juno series.

####Features
- Switch to TLSv1
- Support SR-IOV mechanism driver in ML2
- Implement better nova_admin_tenant_id_setter exists? method
- OVS Agent with ML2: fix symlink on RH plateforms
- Adding portdb and fastpath_flood to n1kv.conf
- Adding vxlan network type support for neutron ML2 plug-in
- Add MidoNet plugin support

####Bugfixes
- Fix l3_ha enablement
- Make cisco plugin symlink coherent
- Fix status messages checks for neutron provider
- Make neutron_plugin_ml2 before db-sync
- Change default MySQL collate to utf8_general_ci
- Fix neutron file_line dependency
- Correct "ip link set" command
- Raise puppet error, if nova-api unavailable
- Do not run neutron-ovs-cleanup for each Puppet run
- Unescape value in parse_allocation_pool
- Fix neutron_network for --router:external setting
- Allow l3_ha to be turned back off after it has been enabled
- Fix support for auth_uri setting in neutron provider
- Reduce neutron API timeout to 10 seconds

####Maintenance
- spec: pin rspec-puppet to 1.0.1
- Pin puppetlabs-concat to 1.2.1 in fixtures
- Update .gitreview file for project rename

##2014-11-21 - 5.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Juno.

####Backwards-incompatible changes
- Migrated the neutron::db::mysql class to use openstacklib::db::mysql, adding
  dependency on openstacklib

####Features
- Add neutron::policy to control policy.json
- Add parameter allow_automatic_l3agent_failover to neutron::agents::l3
- Add parameter metadata_memory_cache_ttl to neutron::agents::metadata
- Add l3_ext as a provider_network_type property for neutron_network type
- Add api_extensions_path parameter to neutron class
- Add database tuning parameters
- Add parameters to enable DVR and HA support in neutron::agents::l3 for Juno
- Make keystone user creation optional when creating a service
- Add the ability to override the keystone service name in
  neutron::keystone::auth
- Add kombu_reconnect_delay parameter to neutron class
- Add neutron::agents::n1kv_vem to deploy N1KV VEM
- Add SSL support for nova_admin_tenant_id_setter
- Deprecated the network_device_mtu parameter in neutron::agents::l3 and moved
  it to the neutron class
- Add vpnaas_agent_package parameter to neutron::services::fwaas to install
  the vpnaas agent package

####Bugfixes
- Change user_group parameter in neutron::agents::lbaas to have different
  defaults depending on operating system
- Change openswan package to libreswan for RHEL 7 for vpnaas
- Ensure neutron package was installed before nova_admin_tenant_id_setter is
  called
- Change management of file lines in /etc/default/neutron-server only for
  Ubuntu
- Fix meaning of manage_service parameter in neutron::agents::ovs
- Fix the enable_dhcp property of neutron_subnet
- Fix bug in parsing allocation pools in neutron_subnet type
- Add relationship to refresh neutron-server when nova_admin_tenant_id_setter
  changes
- Fix the relationship between the HA proxy package and the
  neutron-lbaas-agent package
- Fix plugin.ini error when cisco class is used
- Fix relationship between vs_pridge types and the neutron-plugin-ovs service
- Fix relationship between neutron-server package and neutron_plugin_ml2
  types
- Stop puppet from trying to manage the ovs cleanup service

##2014-10-16 - 4.3.0
###Summary

This is a feature and bugfix release in the Icehouse series.

####Features
- Add parameter to specify number of RPC workers to spawn
- Add ability to manage Neutron ML2 plugin
- Add ability to hide secret neutron configs from logs and fixed password
  leaking
- Add neutron plugin config file specification in neutron-server config
- Add support for Cisco ML2 Mech Driver
- Add parameter to configure dhcp_agent_notification in neutron config
- Add class for linuxbridge support
- Undeprecate enable_security_group parameter

####Bugfixes
- Fix ssl parameter requirements when using kombu and rabbit
- Fix installation of ML2 plugin on Ubuntu
- Fix quotas parameters in neutron config
- Fix neutron-server restart

##2014-07-11 - 4.2.0
###Summary

This is a feature and bugfix release in the Icehouse series.

####Features
- Add ml2/ovs support
- Add multi-region support

####Bugfixes
- Set default metadata backlog to 4096
- Fix neutron-server refresh bug

##2014-06-20 - 4.1.0
###Summary

This is a feature and bugfix release in the Icehouse series.

####Features
- Add parameter to set veth MTU
- Add RabbitMQ SSL support
- Add support for '' as a valid value for gateway_ip

####Bugfixes
- Fix potential OVS resource duplication

####Maintenance
- Pin major gems

##2014-05-01 - 4.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Icehouse.

####Backwards-incompatible changes
- Update security group option for ml2 plugin
- Update packaging changes for Red Hat and Ubuntu systems
- Update parameter defaults to track upstream (Icehouse)

####Features
- Add Neutron-Nova interactions support
- Add external network bridge and interface driver for vpn agent
- Add support for puppetlabs-mysql 2.2 and greater
- Add neutron::config to handle additional custom options
- Add https support to metadata agent
- Add manage_service parameter
- Add quota parameters
- Add support to configure ovs without installing package
- Add support for optional haproxy package management
- Add support to configure plugins by name rather than class name
- Add multi-worker support
- Add isolated network support

####Bugfixes
- Fix bug for subnets with empty values
- Fix typos and misconfiguration in neutron.conf
- Fix max_retries parameter warning
- Fix database creation bugs

##2014-04-15 - 3.3.0
###Summary

This is a feature and bugfix release in the Havana series.

####Features
- Add neutron_port resource
- Add external network bridge for vpn agent

####Bugfixes
- Change dhcp_lease_duration to Havana default of 86400
- Fix VPNaaS installation for Red Hat systems
- Fix conflicting symlink
- Fix network_vlan_ranges parameter for OVS plugin

##2014-03-28 - 3.2.0
###Summary

This is a feature and bugfix release in the Havana series.

####Features
- Add write support for dns, allocation pools, and host routes to Neutron
  router provider

####Bugfixes
- Fix multi-line attribute detection in base Neutron provider
- Fix bugs with neutron router gateway id parsing

##2014-03-26 - 3.1.0
###Summary

This is a feature and bugfix release in the Havana series.

####Features
- Add VXLAN support
- Add support for neutron nvp plugin
- Allow log_dir to be set to false in order to disable file logging
- Add support for https auth endpoints
- Make haproxy package management optional

####Bugfixes
- Configure security group when using ML2 plugin
- Ensure installation of ML2 plugin
- Fix server deprecated warnings
- Tune report and downtime intervals for l2 agent
- Ensure linuxbridge dependency is installed on RHEL
- Improve L3 scheduler support
- Remove strict checks for vlan_ranges
- Fix neutron-metering-agent package for Ubuntu
- Fix VPNaaS service name for Ubuntu
- Fix FWaaS race condition
- Fix ML2 package dependency for Ubuntu
- Remove erronious check for service_plugins

####Maintenance
- Fix improper test for tunnel_types param
- Improve consistency with other puppet modules for OpenStack by prefixing
  database related parameters with database

##2013-12-25 - 3.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Havana.

####Backwards-incompatible changes
- Rename project from quantum to neutron
- Change the default quota_driver

####Features
- Remove provider setting requirement
- Add database configuration support for Havana
- Ensure dnsmasq package resource for compatibility with modules that define
  the same resource
- Add multi-worker support
- Add metering agent support
- Add vpnaas agent support
- Add ml2 plugin support

####Bugfixes
- Fix file permissions
- Fix bug to ensure that keystone endpoint is set before service starts
- Fix lbass driver name

##2013-10-07 - 2.2.0
###Summary

This is a feature and bugfix release in the Grizzly series.

####Features
- Add syslog support
- Add quantum-plugin-cisco package resource

####Maintenance
- Improve documentation
