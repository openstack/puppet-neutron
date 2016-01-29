Puppet::Type.type(:neutron_vpnaas_service_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def file_path
    '/etc/neutron/neutron_vpnaas.conf'
  end

end
