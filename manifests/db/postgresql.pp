#
# Class that configures postgresql for neutron
#
# Requires the Puppetlabs postgresql module.
class neutron::db::postgresql(
  $password,
  $dbname = 'neutron',
  $user   = 'neutron'
) {

  require 'postgresql::python'

  postgresql::db { "${dbname}":
    user      =>  "${user}",
    password  =>  "${password}",
  }

}
