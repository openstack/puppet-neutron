Puppet::Type.type(:neutron_fwaas_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/fwaas_driver.ini'
  end

end
