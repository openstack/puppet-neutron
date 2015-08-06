Puppet::Type.type(:neutron_metadata_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/metadata_agent.ini'
  end

end
