# == Class: neutron::plugins::ml2::networking_ansible
#
# Configures the networking-ansible ML2 Mechanism Driver
#
# === Parameters
#
# [*host_configs*]
#   (required) Network devices and their configurations
# Hash Format:
#
#  {
#     <host1> => {"ansible_network_os" => "junos",
#                 "ansible_host" => "10.0.0.1",
#                 "ansible_user" => 'ansible',
#                 "ansible_ssh_pass" => "***"},
#     <host2> => {"ansible_network_os" => "junos",
#                 "ansible_host" => "10.0.0.2",
#                 "ansible_user" => 'ansible',
#                 "ansible_ssh_private_key_file" => "/private/key"},
#  }
#
# [*package_ensure*]
#   (optional) The intended state of the python-networking-ansible
#   package, i.e. any of the possible values of the 'ensure'
#   property for a package resource type.
#   Defaults to 'present'
#
class neutron::plugins::ml2::networking_ansible(
  $host_configs,
  $package_ensure = 'present',
  ) {
  include ::neutron::deps
  include ::neutron::params

  if($::osfamily != 'RedHat') {
    # Drivers are only packaged for RedHat at this time
    fail("Unsupported osfamily ${::osfamily}")
  }

  ensure_resource('package', 'python2-networking-ansible',
    {
      ensure => $package_ensure,
      tag    => ['openstack', 'neutron-package']
    }
  )
  create_resources(neutron::plugins::ml2::networking_ansible_host, $host_configs)
}
