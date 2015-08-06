Puppet::Type.type(:neutron_plugin_cisco).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/cisco/cisco_plugins.ini'
  end

end
