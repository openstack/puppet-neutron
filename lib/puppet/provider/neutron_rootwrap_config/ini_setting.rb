Puppet::Type.type(:neutron_rootwrap_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/rootwrap.conf'
  end

end
