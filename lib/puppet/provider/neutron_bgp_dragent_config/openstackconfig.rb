Puppet::Type.type(:neutron_bgp_dragent_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/neutron/bgp_dragent.ini'
  end

  # added for backwards compatibility with older versions of inifile
  def file_path
    self.class.file_path
  end

end
