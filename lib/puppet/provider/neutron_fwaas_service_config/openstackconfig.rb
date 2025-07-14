Puppet::Type.type(:neutron_fwaas_service_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/neutron/neutron_fwaas.conf'
  end

end
