Puppet::Type.type(:neutron_plugin_nuage).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/nuage/plugin.ini'
  end

end

