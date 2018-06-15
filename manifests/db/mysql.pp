# The neutron::db::mysql class creates a MySQL database for neutron.
# It must be used on the MySQL server
#
# == Parameters
#
# [*password*]
#   (Required) password to connect to the database.
#
# [*dbname*]
#   (Optional) name of the database.
#   Defaults to neutron.
#
# [*user*]
#   (Optional) user to connect to the database.
#   Defaults to neutron.
#
# [*host*]
#   (Optional) the default source host user is allowed to connect from.
#   Defaults to 'localhost'
#
# [*allowed_hosts*]
#   (Optional) other hosts the user is allowed to connect from.
#   Defaults to undef.
#
# [*charset*]
#   (Optional) the database charset.
#   Defaults to 'utf8'
#
# [*collate*]
#   (Optional) the database collation.
#   Defaults to 'utf8_general_ci'
#
class neutron::db::mysql (
  $password,
  $dbname        = 'neutron',
  $user          = 'neutron',
  $host          = '127.0.0.1',
  $allowed_hosts = undef,
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
) {

  include ::neutron::deps

  validate_string($password)

  ::openstacklib::db::mysql { 'neutron':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

  Anchor['neutron::db::begin']
  ~> Class['neutron::db::mysql']
  ~> Anchor['neutron::db::end']
}
