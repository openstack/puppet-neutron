Puppet::Type.type(:neutron_taas_service_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/neutron/taas_plugin.ini'
  end

end
