Puppet::Type.type(:neutron_sriov_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/ml2/sriov_agent.ini'
  end
end
