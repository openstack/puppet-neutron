Puppet::Type.type(:neutron_sfc_service_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/neutron/conf.d/neutron-server/networking-sfc.conf'
  end

end
