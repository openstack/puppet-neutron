Puppet::Type.type(:neutron_l2gw_service_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/neutron/networking_l2gw.conf'
  end

end
