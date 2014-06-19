#
# Configure the Mech Driver for cisco neutron plugin
# More info available here:
# https://wiki.openstack.org/wiki/Neutron/ML2/MechCiscoNexus
#
#
# neutron::plugins::ml2::cisco::nexus_creds used by
# neutron::plugins::ml2::cisco::nexus
#

define neutron::plugins::ml2::cisco::nexus_creds(
  $username,
  $password,
  $servers,
  $ip_address,
  $ssh_port
) {

  neutron_plugin_cisco_credentials {
    "${username}/username": value => $username;
    "${password}/password": value => $password;
  }

  exec {'nexus_creds':
    unless  => "/bin/cat /var/lib/neutron/.ssh/known_hosts | /bin/grep ${username}",
    command => "/usr/bin/ssh-keyscan -t rsa ${username} >> /var/lib/neutron/.ssh/known_hosts",
    user    => 'neutron',
    require => Package['neutron-server']
  }
}
