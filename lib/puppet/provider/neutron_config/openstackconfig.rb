Puppet::Type.type(:neutron_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def file_path
    '/etc/neutron/neutron.conf'
  end

end
