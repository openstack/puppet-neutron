Puppet::Type.type(:neutron_lbaas_service_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def file_path
    '/etc/neutron/neutron_lbaas.conf'
  end

end
