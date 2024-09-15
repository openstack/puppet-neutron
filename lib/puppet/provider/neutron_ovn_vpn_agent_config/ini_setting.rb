Puppet::Type.type(:neutron_ovn_vpn_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/ovn_vpn_agent.ini'
  end

end
