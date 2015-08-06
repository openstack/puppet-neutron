Puppet::Type.type(:neutron_plugin_cisco_credentials).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/cisco/credentials.ini'
  end

end
