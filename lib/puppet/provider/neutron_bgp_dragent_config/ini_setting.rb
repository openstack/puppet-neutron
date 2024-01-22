Puppet::Type.type(:neutron_bgp_dragent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/bgp_dragent.ini'
  end

end
