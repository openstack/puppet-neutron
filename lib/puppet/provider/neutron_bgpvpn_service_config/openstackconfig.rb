Puppet::Type.type(:neutron_bgpvpn_service_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/neutron/networking_bgpvpn.conf'
  end

end
