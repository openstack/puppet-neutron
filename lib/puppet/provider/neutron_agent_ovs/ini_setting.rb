Puppet::Type.type(:neutron_agent_ovs).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/plugins/ml2/openvswitch_agent.ini'
  end

end
