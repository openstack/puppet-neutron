Puppet::Type.type(:neutron_l3_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/l3_agent.ini'
  end

end
