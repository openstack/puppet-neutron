Puppet::Type.type(:neutron_plugin_opencontrail).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/opencontrail/ContrailPlugin.ini'
  end

end
