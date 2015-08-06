Puppet::Type.type(:neutron_vpnaas_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/vpn_agent.ini'
  end

end
