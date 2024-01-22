Puppet::Type.type(:neutron_agent_macvtap).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/plugins/ml2/macvtap_agent.ini'
  end

end
