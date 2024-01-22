Puppet::Type.type(:neutron_bgpvpn_bagpipe_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/neutron/bagpipe-bgp/bgp.conf'
  end

end
