Puppet::Type.type(:neutron_plugin_midonet).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/midonet/midonet.ini'
  end

end
