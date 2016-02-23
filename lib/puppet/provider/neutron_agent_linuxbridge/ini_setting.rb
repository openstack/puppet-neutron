Puppet::Type.type(:neutron_agent_linuxbridge).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini'
  end

end
