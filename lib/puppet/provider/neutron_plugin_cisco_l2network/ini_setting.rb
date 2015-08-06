Puppet::Type.type(:neutron_plugin_cisco_l2network).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/cisco/l2network_plugin.ini'
  end

end
