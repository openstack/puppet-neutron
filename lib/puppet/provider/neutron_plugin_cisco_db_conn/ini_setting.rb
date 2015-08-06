Puppet::Type.type(:neutron_plugin_cisco_db_conn).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/cisco/db_conn.ini'
  end

end
