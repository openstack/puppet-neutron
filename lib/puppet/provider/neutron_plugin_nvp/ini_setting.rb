Puppet::Type.type(:neutron_plugin_nvp).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/nicira/nvp.ini'
  end

end
